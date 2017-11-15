part of forex_classes;
class User
{

  String id;
  String status;
  Map<String,Account> Accounts;
  User()
  {
    Accounts=new Map<String,Account>();
    Accounts["primary"]=new Account();
    Accounts["primary"].id="primary";

    Accounts["secondary"]=new Account();
    Accounts["secondary"].id="secondary";
  }
  Account get primaryAccount => Accounts["primary"];
  Account get secondaryAccount => Accounts["secondary"];
  User.fromJson(String json)
  {
    Map jsonNode = JSON.decode(json);
    setUser(jsonNode);
  }

  User.fromJsonMap(Map jsonNode)
  {
    setUser(jsonNode);
  }

  setUser(Map jsonNode)
  {
    id = jsonNode["id"];
    status = jsonNode["status"];

    Accounts = new Map<String,Account>();
    Accounts["primary"]=new Account.fromJsonMap(jsonNode["Accounts"]["primary"]);
    Accounts["secondary"]=new Account.fromJsonMap(jsonNode["Accounts"]["secondary"]);



    /* for(Map acc in jsonNode["Accounts"])
    {
       Accounts.add(new Account.fromJsonMap(acc));
    }*/
    //Accounts=jsonNode["Accounts"];
  }

  String toJson()
  {
    return JSON.encode(toJsonMap());
  }

  Map toJsonMap()
  {
    Map MapAccounts = new Map();

    MapAccounts["primary"]=Accounts["primary"].toJson();
    MapAccounts["secondary"]=Accounts["secondary"].toJson();
    return {"_id":id,"id":id,"status":status,"Accounts":MapAccounts};
  }
  num RealizedPL()
  {
    num balance =0;
    //for(Account acct in Accounts)
    //{
    balance=primaryAccount.RealizedPL()+ secondaryAccount.RealizedPL();
    //}

    return balance;
  }

  num UnRealizedPL()
  {
    num balance =0;
    //for(Account acct in Accounts)
    //{
    balance=primaryAccount.UnrealizedPL()+ secondaryAccount.UnrealizedPL();
    //}

    return balance;
  }

  num Cash()
  {
    return primaryAccount.cash + secondaryAccount.cash;
  }

  num MarginUsed()
  {
    return primaryAccount.MarginUsed()+secondaryAccount.MarginUsed();
  }

  num MarginAvailable()
  {
    return primaryAccount.MarginAvailable()+secondaryAccount.MarginAvailable();
  }

  num NetAssetValue()
  {
    num balance =0;

    balance=primaryAccount.NetAssetValue()+secondaryAccount.NetAssetValue();

    return balance;
  }

  num PL()
  {
    return UnRealizedPL() + RealizedPL();
  }
  List<String> AllTradingPairs()
  {
    List<Trade> allTrades = new List<Trade>.from(primaryAccount.Trades)
                        ..addAll(primaryAccount.closedTrades)
                        ..addAll(secondaryAccount.Trades)
                        ..addAll(secondaryAccount.closedTrades);
    var pairSet = new Set.from(allTrades.map((trade)=>trade.pair).toList());
    return pairSet.toList();
  }

  List<String> TradingPairs()
  {
    List<String> pairs= new List<String>();

    for(Trade currTrade in new List<Trade>.from(primaryAccount.Trades)..addAll(secondaryAccount.Trades))
    {
      if(!pairs.contains(currTrade.pair))
      {
        pairs.add(currTrade.pair);
      }
    }
    return pairs;
  }

  updateTrades(String pair,String dt,double price)
  {
    primaryAccount.updateTrades(pair, dt, price);
    secondaryAccount.updateTrades(pair, dt, price);

  }

  updateTradesPrice(Price currPrice)
  {
    primaryAccount.updateTradesPrice(currPrice);
    secondaryAccount.updateTradesPrice(currPrice);
  }

  List<Trade> closedTrades()
  {
    return new List<Trade>.from(primaryAccount.closedTrades)..addAll(secondaryAccount.closedTrades);
  }

  updateHistory(String dt)
  {
    primaryAccount.AddHistory(dt,primaryAccount.NetAssetValue());
    secondaryAccount.AddHistory(dt,primaryAccount.NetAssetValue());
  }

  fundAccount(String acc,double amount)
  {
    if(acc=="primary")
      primaryAccount.fundAccount(amount);
    else
      secondaryAccount.fundAccount(amount);
  }

  closeTrade(String acc,int index)
  {
    if(acc=="primary")
      primaryAccount.closeTrade(index);
    else
      secondaryAccount.closeTrade(index);
  }

  executeTrade(String acc,String pair, int units,String position,String openDate,double stopLoss,double takeProfit)
  {
    Trade trade1 = new Trade();
    trade1.pair=pair;
    trade1.units=units;
    trade1.openDate=openDate;
    trade1.closeDate=openDate;
    trade1.stopLoss=stopLoss;
    trade1.takeProfit=takeProfit;
    if(position=="long")
      trade1.long=true;
    else
      trade1.long=false;

    if(acc=="primary")
      primaryAccount.executeTrade(trade1);
    else
      secondaryAccount.executeTrade(trade1);

  }

  executeTradePriceStrategy(String acc,Price price,Strategy currStrategy)
  {
     executeTrade(acc, price.instrument,
         currStrategy.units,
         currStrategy.position,
         price.time.toIso8601String(),
         currStrategy.stopLoss * price.bid,
         currStrategy.takeProfit*price.bid);
  }

  printacc()
  {
    print("Primary Account");
    primaryAccount.printacc();

    print("Secondary Account");
    secondaryAccount.printacc();

    print("User PL "+PL().toString());
    print("User Net Value "+NetAssetValue().toString());
    print("User Cash Balance "+Cash().toString());
  }



  processOrdersNew(String pair,double currentValue)
  {
    primaryAccount.processOrdersNew(pair,currentValue);
    secondaryAccount.processOrdersNew(pair,currentValue);
  }

  processOrdersNewPrice(Price currPrice)
  {
    primaryAccount.processOrdersNew(currPrice.instrument,currPrice.bid);
    secondaryAccount.processOrdersNew(currPrice.instrument,currPrice.bid);
  }

  setStopLoss(String acc,Trade trade,double price)
  {
    if(acc=="primary")
      primaryAccount.setStopLoss(trade, price);
    else
      secondaryAccount.setStopLoss(trade, price);

  }

  setTakeProfit(String acc,Trade trade,double price)
  {
    if(acc=="primary")
      primaryAccount.setTakeProfit(trade, price);
    else
      secondaryAccount.setTakeProfit(trade, price);
  }

  setOrder(String acc,String openDate,int index,double price,bool direction)
  {
    if(acc=="primary")
      primaryAccount.setOrder(index,openDate,price,direction);
    else
      secondaryAccount.setOrder(index,openDate,price,direction);
  }

  transferAmount(String from,String to,double amount) {
    if (from == "primary")
    {
      primaryAccount.cash-=amount;
      secondaryAccount.cash+=amount;
    }
    else
    {
      secondaryAccount.cash-=amount;
      primaryAccount.cash+=amount;
    }
  }

}