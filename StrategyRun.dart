import 'dart:async';
import 'package:intl/intl.dart';
import 'lib/forex_mongo.dart';
import 'lib/forex_classes.dart';
import 'lib/forexclasses/forex_cache.dart';
import 'lib/forex_indicator_rules.dart';
import 'lib/forex_prices.dart';
main(List<String> arguments) async
{
	var arg = "debug";
	var isProcessing = false;
	if (arguments.length > 0)
		arg = arguments[0];
	ForexMongo mongoLayer = new ForexMongo(arg);
	await mongoLayer.db.open();




	PercentageComplete(DateTime currentDay, DateTime endDate,
			int sessionDuration) {
		Duration remainingTime = endDate.difference(currentDay);
		return ((sessionDuration - remainingTime.inDays) / sessionDuration) * 100.0;
	}

	DeleteHangingSessions() async
	{
		await for(Map sessionMap in mongoLayer.getSessions())
		{
			//TradingSession session = new TradingSession.fromJSONMap(sessionMap);
			if(await mongoLayer.isHanging(sessionMap["experimentId"],sessionMap["sessionType"]))
			{
				mongoLayer.deleteSession(sessionMap["id"]);
				print(sessionMap["id"] + " deleted");
			}
		}
	}

	ProcessTradingSession(ForexMongo mongoLayer) async
	{
		if(isProcessing)
		{
			return;
		}
		else
		{
			await DeleteHangingSessions();
		}

		isProcessing=true;
		var tradingSessionMap = await mongoLayer.popTradingSession();
		if (tradingSessionMap != null) {
			//TradingSession tradingSession = new TradingSession.fromJSONMap(
			//		tradingSessionMap["tradingsession"]);
			Stopwatch watch = new Stopwatch();
			watch.start();
			TradingSession tradingSession = new TradingSession();
			tradingSession.id=tradingSessionMap["name"];
			//tradingSession1.strategy=strategy1;
			tradingSession.startDate=DateTime.parse(tradingSessionMap["startdate"]);
			tradingSession.currentTime=tradingSession.startDate;
			tradingSession.endDate=DateTime.parse(tradingSessionMap["enddate"]);
			tradingSession.strategy = new Strategy.fromJsonMap(tradingSessionMap["strategy"]);
			tradingSession.fundAccount("primary", tradingSessionMap["startamount"]);//
			tradingSession.experimentId=tradingSessionMap["experimentId"];

			print(tradingSession.strategy.ruleName);

			IndicatorRule tradingRule = new IndicatorRule(
					tradingSession.strategy.ruleName, tradingSession.strategy.window);
			List<IndicatorRule> rules = new List<IndicatorRule>();
			rules.add(tradingRule);

			DateFormat formatter = new DateFormat('yyyyMMdd');
			int sessionRange = tradingSession.endDate
					.difference(tradingSession.startDate)
					.inDays;
			ForexCache cache = new ForexCache(
					formatter.format(tradingSession.currentTime),
					formatter.format(tradingSession.endDate), rules);
			await cache.buildCacheMongo(mongoLayer);
			print("cache built!");

			for (var dailyPairValues in cache.DailyValues())
			{
				for (Map dailyPairValue in dailyPairValues)
				{
					if (dailyPairValue[tradingSession.strategy.ruleName])
					{
						Map initPrice = await mongoLayer.readPricesAsyncByDate(dailyPairValue['pair'], DateTime.parse(dailyPairValue['date'])).first;
						tradingSession.executeTradeStrategyPrice("primary",
								tradingSession.strategy,
								new Price.fromJsonMap(initPrice));
					}

					await for (Map priceMap in mongoLayer.readPricesAsyncByDate(dailyPairValue['pair'], DateTime.parse(dailyPairValue['date'])))
					{
						tradingSession.updateSessionPriceNoHist(new Price.fromJsonMap(priceMap));
					}

					Map lastPrice = await mongoLayer.readPricesAsyncByDate(dailyPairValue['pair'], DateTime.parse(dailyPairValue['date'])).last;
					tradingSession.updateSessionPrice(new Price.fromJsonMap(lastPrice));

				}
				await mongoLayer.saveSession(tradingSession);
				tradingSession.percentComplete = PercentageComplete(tradingSession.currentTime, tradingSession.endDate, sessionRange);
				print("${dailyPairValues[0]['date']} ${tradingSession.percentComplete}");

			}

			tradingSession.percentComplete = 100.0;
			tradingSession.printacc();
			watch.stop();
			print(watch.elapsed.inSeconds.toString());
			tradingSession.elapsedTime = watch.elapsed.inSeconds.toString();
			tradingSession.endSessionTime = new DateTime.now().toIso8601String();
			await mongoLayer.saveSession(tradingSession);
      tradingSessionMap["read"] = true;

      await mongoLayer.saveSessionQueue(tradingSessionMap);
		}
		isProcessing=false;

	}




	const period = const Duration(seconds: 3);
	new Timer.periodic(
			period, (Timer t) async => await ProcessTradingSession(mongoLayer));
}