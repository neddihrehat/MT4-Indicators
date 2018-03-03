//+------------------------------------------------------------------+
//|                                                   Neds Indicators|
//|                                      Copyright 2016, Neddihrehat |
//+------------------------------------------------------------------+
// Please report any bug you occur

#property indicator_chart_window
#property indicator_buffers 2

#property indicator_color1 White
#property indicator_color2 White
#property indicator_width1 0
#property indicator_width2 0

extern string NOTE1="Rules";
extern bool testOC = true;
extern bool testHL = true;
extern bool testTwoBarOC = true;
extern bool testOneBarMA = true;
extern bool testTwoBarMA = true;
extern bool testATR = true;
extern bool testStoch = true;
extern int barsToTest = 50;
//+------------------------------------------------------------------+
extern string NOTE="Alert Settings";
extern bool ShowArrows=True;
extern bool VerticalLines=False;
extern ENUM_LINE_STYLE LineStyle=STYLE_DASH;
extern color UPColor=clrGreen;
extern color DownColor=clrRed;
int    ArrowsUpCode       = 233;
int    ArrowsDnCode       = 234;

extern bool   AlertsOn        = True;
extern bool   AlertsOnCurrent = True;
bool   AlertsMessage=True;
string UniqueID="Ned_TrendFriend";

//+------------------------------------------------------------------+

double ArrowsBuy[],ArrowsSell[],Trend[];
bool up=False;
//+------------------------------------------------------------------+

int init()
  {
   IndicatorBuffers(6);
   SetIndexBuffer(0,ArrowsBuy);     SetIndexStyle(0,DRAW_ARROW,NULL,NULL,UPColor); SetIndexArrow(0,ArrowsUpCode);
   SetIndexBuffer(1,ArrowsSell);    SetIndexStyle(1,DRAW_ARROW,NULL,NULL,DownColor); SetIndexArrow(1,ArrowsDnCode);
   SetIndexBuffer(2,Trend);

//+------------------------------------------------------------------+

   SetIndexLabel(0,"Up Signal");
   SetIndexLabel(1,"Down Signal");

   if(!ShowArrows) { SetIndexStyle(0,DRAW_NONE); SetIndexStyle(1,DRAW_NONE); }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   DeleteThings();
//+------------------------------------------------------------------+
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit = barsToTest > 5 ? barsToTest : MathMin(Bars-counted_bars,Bars-1);

//+------------------------------------------------------------------+
   bool sellrules,buyrules;
   double fastMA[], slowMA[], stochValue, stochSignal, ATR[];
   
   ArrayResize( fastMA, limit);
   ArraySetAsSeries(fastMA,true);
   ArrayResize( slowMA, limit);
   ArraySetAsSeries(slowMA,true);
   ArrayResize( ATR, limit);
   ArraySetAsSeries(ATR,true);      
   
   for(int i=limit; i>=0; i--)
     {
      slowMA[i] = iMA(NULL,0,3,0,3,6,i);  
      fastMA[i] = iMAOnArray(slowMA, 0, 2, 1, MODE_LWMA, i);
      ATR[i] = iATR(NULL,0, 14, i);
      stochValue = iStochastic(NULL,0,6,3,4,MODE_SMA,0,MODE_MAIN,i);
      stochSignal = iStochastic(NULL,0,6,3,4,MODE_SMA,0,MODE_SIGNAL,i);      
      
      
      sellrules= (testOC ? isBear(i+1) && (isBull(i) || isDoji(i)) : true) 
                 && (testTwoBarOC ? isBear(i+2) : true) 
                 && (testHL ? isLower(i+1) && (High[i] < High[i+2]) : true)
                 && (testOneBarMA ? slowMA[i] < fastMA[i] && slowMA[i+1] < fastMA[i+1]  : true)
                 && (testTwoBarMA ? slowMA[i+2] < fastMA[i+2] : true)
                 && (testStoch ? stochValue < stochSignal : true)
                 && (testATR ? (ATR[i] > ATR[i+2] && ATR[i+1] > ATR[i+2]) : true);
                 
      buyrules = (testOC ? isBull(i+1) && (isBear(i) || isDoji(i)) : true) 
                 && (testTwoBarOC ? isBull(i+2) : true) 
                 && (testHL ? isHigher(i+1) && (Low[i] > Low[i+2]) : true)
                 && (testOneBarMA ? slowMA[i] > fastMA[i] && slowMA[i+1] > fastMA[i+1]   : true)
                 && (testTwoBarMA ? slowMA[i+2] > fastMA[i+2] : true)
                 && (testStoch ? stochValue > stochSignal : true)
                 && (testATR ? (ATR[i] > ATR[i+2] && ATR[i+1] > ATR[i+2]) : true);
      
      Trend[i]=Trend[i+1];
      if(// SELL
         sellrules
         ) Trend[i]=-1;

      else if(// BUY
         buyrules
         ) Trend[i]=1;
      else    Trend[i]=0;

      ArrowsBuy[i]    = EMPTY_VALUE;
      ArrowsSell[i]   = EMPTY_VALUE;

      if(Trend[i]!=Trend[i+1] && Trend[i]==1)
        {
         ArrowsBuy[i]=Low[i];
         if(AlertsOn)
           {
            doAlert(0,"Call Signal");
            up=True;
           }
         if(VerticalLines) CreateVLine(UniqueID+"Line"+i+Time[i],Time[i],UPColor);
        }
      else if(Trend[i]!=Trend[i+1] && Trend[i]==-1)
        {
         ArrowsSell[i]=High[i];
         if(AlertsOn)
           {

            doAlert(0,"Put Signal");
            up=False;

           }
         if(VerticalLines) CreateVLine(UniqueID+"Line"+i+Time[i],Time[i],DownColor);
        }

     }
   return 0;
  }

bool isDoji(int i){
   return Open[i] == Close[i];
}

bool isBear(int i){
   return Open[i]>Close[i];
}

bool isBull(int i){
   return Open[i]<Close[i];
}

bool isLower(int i){
   return Low[i] < Low[i+1];
}

bool isHigher(int i){
   return High[i] > High[i+1];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateVLine(string LineName,datetime time,color LineColor)
  {
   ObjectCreate(LineName,OBJ_VLINE,0,time,0);
   ObjectSet(LineName,OBJPROP_STYLE,LineStyle);
   ObjectSet(LineName,OBJPROP_COLOR,LineColor);
   ObjectSet(LineName,OBJPROP_HIDDEN,true);
   ObjectSet(LineName,OBJPROP_SELECTABLE,false);
   ObjectSet(LineName,OBJPROP_BACK,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteThings()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string name  = UniqueID;
      string label = ObjectName(i);
      if(StringSubstr(label,0,StringLen(name))!=name)
         continue;
      ObjectDelete(label);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar,string doWhat)
  {
   static string   previousAlert="Nothing";
   static datetime previousTime;
   string message;

   if(previousAlert!=doWhat && previousTime!=Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];

      message=StringConcatenate(Symbol()," - ",TimeFrameToString(Period())," - "+UniqueID+": ",doWhat);
      if(AlertsMessage) Alert(message);
      //if (AlertsCopier)  signalcopier(Symbol(),doWhat,Expiry);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeFrameToString(int tf)
  {
   string tfs;

   switch(tf)
     {
      case PERIOD_M1:     tfs = "M1";      break;
      case PERIOD_M5:     tfs = "M5";      break;
      case PERIOD_M15:    tfs = "M15";     break;
      case PERIOD_M30:    tfs = "M30";     break;
      case PERIOD_H1:     tfs = "H1";      break;
      case PERIOD_H4:     tfs = "H4";      break;
      case PERIOD_D1:     tfs = "D1";      break;
      case PERIOD_W1:     tfs = "W1";      break;
      case PERIOD_MN1:    tfs = "MN";
      default: tfs="M"+DoubleToStr(tf,0);
     }
   return(tfs);
  }
//+------------------------------------------------------------------+
