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

extern string NOTE1="Only set 1 as true";
extern bool CFBOriginal=False;
extern bool CFBMod=True;
//+------------------------------------------------------------------+
extern string NOTE2="Alert Settings";
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
string UniqueID="Neds_CFB";

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
   int limit=MathMin(Bars-counted_bars,Bars-1);

//+------------------------------------------------------------------+
   bool sellrules,buyrules;
   for(int i=limit; i>=0; i--)
     {
      if(CFBOriginal)
        {
         sellrules = (High[i]>High[i+1] && Open[i+1]<Close[i+1] && High[i+1]>Close[i]);
         buyrules  = (Low[i]<Low[i+1]&& Open[i+1]>Close[i+1]&& Low[i+1]<Close[i]);
        }
      else if(CFBMod)
        {
         sellrules=(High[i]>High[i+1] && Open[i+1]<Close[i+1] && Open[i]>Close[i]);
         buyrules =(Low[i]<Low[i+1]&& Open[i+1]>Close[i+1]&& Open[i]<Close[i]);
        }

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
