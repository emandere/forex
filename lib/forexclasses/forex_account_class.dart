part of forex_classes;
class Account
{
  String id;
  String _id;
  double cash;
  double realizedPL;
  double Margin;
  double MarginRatio;
  int idcount;
  List<Trade> Trades;
  List<Trade> closedTrades;
  List<Order> orders;
  List<Map<String,double>> balanceHistory;
  //List<Order> OpenOrder;
  //List<Order> ClosedOrder;
  //List balanceHistory;
  Account()
  {
    realizedPL=0.0;
    cash =0.0;
    Margin =0.0;
    MarginRatio=50.0;
    Trades = new List<Trade>();
    closedTrades = new List<Trade>();
    orders = new List<Order>();
    balanceHistory= new List<Map<String,double>> ();
    idcount=0;
  }

  AddHistory(String dt,double amount)
  {
    balanceHistory.add({"date":dt,"amount":amount});
  }

  fundAccount(double amount)
  {
    cash+=amount;
  }

  closeTrade(int index)
  {
    Trade moveTrade = Trades.firstWhere((Trade i)=>i.id==index);//Trades[index];
    int tradeIndex = Trades.indexOf(moveTrade);
    realizedPL+=moveTrade.PL();
    cash+=moveTrade.PL();
    closedTrades.add(moveTrade);
    Trades.removeAt(tradeIndex);

  }

  Account.fromJsonMap(Map jsonNode)
  {
    setAccount(jsonNode);
  }

  executeTrade(Trade trade)
  {
    //balance = balance - (trade.units * trade.openPrice);
    bool matchTrade(Trade i)
    {
      if(i.pair==trade.pair && i.units==trade.units && i.openDate==trade.openDate && (i.long!=trade.long))
        return true;
      else
        return false;

    }

    if(Trades.isNotEmpty)
    {
      Trade oppositeTrade = Trades.firstWhere(matchTrade, orElse: () => null);
      //int index = Trades.indexOf(oppositeTrade);
      if (oppositeTrade == null)
      {
        trade.id = idcount;
        Trades.add(trade);

        idcount++;
      }
      else
      {
        //print("removing");
        closeTrade(oppositeTrade.id);
      }
    }
    else
    {
      trade.id = idcount;
      Trades.add(trade);

      idcount++;
    }

  }

  setStopLoss(Trade trade,double price)
  {
    if(trade.long)
      setOrder(trade.id,trade.openDate,price,false);
    else
      setOrder(trade.id,trade.openDate,price,true);

  }

  setTakeProfit(Trade trade,double price)
  {
    if(trade.long)
      setOrder(trade.id,trade.openDate,price,true);
    else
      setOrder(trade.id,trade.openDate,price,false);

  }

  setOrder(int index,String openDate,double price,direction)
  {
    Trade stopTrade = new Trade();
    Trade trade = Trades.firstWhere((Trade i)=>i.id==index,orElse: () => null);
    if(trade!=null)
    {
      stopTrade.pair = trade.pair;
      stopTrade.units = trade.units;
      stopTrade.long = !trade.long;
      stopTrade.openDate = openDate;

      Order stopLossOrder = new Order(stopTrade,price,direction);
      orders.add(stopLossOrder);
    }
    else
    {
      print("order failed");
    }
  }

  setAccount(jsonNode)
  {

    id=jsonNode["id"];
    realizedPL=double.parse(jsonNode["realizedPL"].toString());
    Margin = double.parse(jsonNode["Margin"]?.toString()??"0.0");
    MarginRatio = double.parse(jsonNode["MarginRatio"]?.toString()??"50.0");
    cash=double.parse(jsonNode["cash"].toString());
    idcount=jsonNode["idcount"];
    Trades=new List<Trade>();
    closedTrades = new List<Trade>();
    orders=new List<Order>();
    for(Map trade in jsonNode["Trades"])
    {
      Trades.add(new Trade.fromJsonMap(trade));
    }

    for(Map trade in jsonNode["closedTrades"])
    {
      closedTrades.add(new Trade.fromJsonMap(trade));
    }

    for(Map order in jsonNode["orders"]??[])
    {
      orders.add(new Order.fromJsonMap(order));
    }

    balanceHistory = jsonNode["balanceHistory"];
    /* for(Map day in jsonNode["balanceHistory"])
    {
      balanceHistory.add(day);
    }*/
  }

  Map toJson()
  {
    List<Map> MapTrades = new List<Map>();
    List<Map> MapClosedTrades = new List<Map>();
    List<Map> MapOrders=new List<Map>();
    for(Trade trade in Trades)
    {
      MapTrades.add(trade.toJson());
    }

    for(Trade trade in closedTrades)
    {
      MapClosedTrades.add(trade.toJson());
    }

    for(Order order in orders)
    {
      MapOrders.add(order.toJson());
    }

    return {
      "id":id,
      "cash":cash,
      "Margin":Margin,
      "MarginRatio":MarginRatio,
      "realizedPL":realizedPL,
      "Trades":MapTrades,
      "orders":MapOrders,
      "closedTrades":MapClosedTrades,
      "balanceHistory":balanceHistory,
      "idcount":idcount
    };
  }
  num RealizedPL()
  {
    double tradeAmount=0.0;
    for(Trade closedTrade in closedTrades)
    {
      tradeAmount += closedTrade.PL();
    }
    return tradeAmount;
  }

  num UnrealizedPL()
  {
    double tradeAmount=0.0;
    for(Trade currTrade in Trades)
    {
      tradeAmount += currTrade.PL();
    }
    return tradeAmount;
  }

  num PL()
  {
    return RealizedPL() + UnrealizedPL();
  }

  num NetAssetValue()
  {
    return cash + UnrealizedPL();
  }

  num MarginUsed()
  {
    double margin=0.0;
    for(Trade currTrade in Trades)
    {
      margin += currTrade.value()/MarginRatio;
    }
    return margin;
  }

  num MarginAvailable()
  {
    return NetAssetValue() - MarginUsed();
  }

  double averageTradePL()
  {
    if(closedTrades.isNotEmpty)
    {
      var PLList = closedTrades.map((x) => x.PL()).toList();
      return Average(PLList);
    }
    else
    {
      return 0.0;
    }
  }

  double stdDevTradePL()
  {
    if(closedTrades.isNotEmpty)
    {
      var PLList = closedTrades.map((x) => x.PL()).toList();
      return StdDev(PLList);
    }
    else
    {
      return 0.0;
    }
  }


  printacc()
  {

    for(Trade currTrade in Trades)
    {
      print(currTrade.id.toString()+" "+ currTrade.pair+" "+currTrade.units.toString()+" "+currTrade.PL().toString());
    }
    print("PL "+PL().toString());
    print("Net Value "+NetAssetValue().toString());
    print("Margin Used "+MarginUsed().toString());
    print("Margin Available "+MarginAvailable().toString());
    print("Cash Balance "+cash.toString());
    print("Average Realized PL "+averageTradePL().toString());
    print("Std Dev Realized PL "+stdDevTradePL().toString());
    printAverageClosedTradeByPair();
    int DateDiff(Trade trade)
    {
      DateTime openDate = DateTime.parse(trade.openDate);
      DateTime closeDate = DateTime.parse(trade.closeDate);
      return closeDate.difference(openDate).inDays;
    }

    for(Trade closedTrade in closedTrades)
    {
      if(DateDiff(closedTrade)<0)
        print("${closedTrade.id.toString()} ${closedTrade.pair} ${closedTrade.openDate} ${closedTrade.closeDate}");
    }
  }

  printAverageClosedTradeByPair()
  {
    selectByName(String pair)=>closedTrades
        .where((trade)=>trade.pair==pair)
        .map((trade)=>trade.PL());

    var pairs = closedTrades.map((trade)=>trade.pair)
        .toSet();

    var averageByPair = pairs.map(selectByName)
        .map(Average);

    var averageByPairListZip = new IterableZip([pairs,averageByPair]);

    averageByPairListZip.forEach(print);

  }


  processOrdersNew(String pair,double currentValue)
  {

    for(Order order in orders)
    {

      bool matchOppositeOrder(Order x)
      {
        return x.trade.pair==order.trade.pair
            && x.above!=order.above
            && x.trade.openDate==order.trade.openDate;
      }

      if(!order.expired)
      {
        if(order.trade.pair==pair && order.checkTrigger(currentValue))
        {
          //print("processed start event " +order.trade.pair +" "+order.trade.openDate+" "+Trades.length.toString());
          executeTrade(order.trade);
          //print("processed end event " +order.trade.pair +" "+order.trade.openDate+" "+Trades.length.toString());
          order.expired = true;
          var twinOrder = orders.firstWhere(matchOppositeOrder,orElse: () => null);
          twinOrder?.expired=true;
        }
      }
    }
  }

  updateTrades(String pair,String dt,double price)
  {
    for(Trade currTrade in Trades)
    {
      if(currTrade.pair==pair)
      {
        currTrade.updateTrade(dt,price);
      }
    }

  }

  updateTradesPrice(Price currPrice)
  {
    List<Trade> selectedTrades = Trades.where((trade)=>trade.pair==currPrice.instrument).toList();
    for(Trade currTrade in selectedTrades)
    {
      currTrade.updateTrade(currPrice.time.toIso8601String(), currPrice.bid);
    }
  }

  void Deposit(num amt)
  {

  }

  void WithDraw(num amt)
  {

  }



}