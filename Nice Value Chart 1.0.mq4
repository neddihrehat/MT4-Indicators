#property copyright "Nedd"
#property link      "www.binaryoptionsedge.com/user/958-neddihrehat/"
#property version   "1.0"
#property description "A Nice Value Chart that lets you control things you want and ignore things you don't want from a VC indicator. :) "

#property indicator_separate_window
#property indicator_levelcolor RoyalBlue
#property indicator_levelstyle 2
#property indicator_buffers 4
#property indicator_color1 CLR_NONE
#property indicator_color2 CLR_NONE
#property indicator_color3 CLR_NONE
#property indicator_color4 CLR_NONE
#property indicator_level1 8
#property indicator_level2 -8
#property indicator_minimum -15
#property indicator_maximum 15

extern string Note1 = "___________Calculation___________";
extern int NumBars = 5;
extern int MaxBars = 25;

extern int OBLevel= 8;
extern int OSLevel= -8;

extern string Note2 = "____________Design And Alerts____________";
extern bool Alerts = True;
extern bool SoundOnly = False;
extern string SoundOnlyFile = "alert.wav";
extern int CandleSize=4;
extern color Up = LimeGreen;
extern color Down = Orange;
extern color OB= Green;
extern color OS= Red;

extern bool EnableColoredLevelLine = True;
extern color UpColor = Green;
extern color DownColor = Red;

extern bool EnablePriceLine = False;
extern color PriceLineColor = Black;


extern string Note3 = "+++_____Expert_____+++";
extern bool HideInfo = False;

static datetime time_alert;
// Alert Function
void ShowAlert(string message)
  {
      string FinalMessage = IndicatorName +" "+ Symbol()+","+Period()+" | "+message;
      Print(FinalMessage);
      if(SoundOnly == false){Alert(FinalMessage);}
      if(SoundOnly == True) {PlaySound(SoundOnlyFile);}
  }
  
double OO[];
double HH[];
double LL[];
double CC[];

string IndicatorName="Nice Value Chart RID:"+(MathRand()%9999999999);

int init() {

string OpenLabel, HighLabel, LowLabel, CloseLabel;
if(HideInfo==True){
   OpenLabel = NULL;
   HighLabel = NULL;
   LowLabel = NULL;
   CloseLabel = NULL;
}
else{
   OpenLabel = "Open";
   HighLabel = "High";
   LowLabel = "Low";
   CloseLabel = "Close";
}

   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, OO);
   SetIndexLabel(0,OpenLabel);
   
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, HH);
   SetIndexLabel(1,HighLabel);
   
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, LL);
   SetIndexLabel(2,LowLabel);
   
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, CC);
   SetIndexLabel(3,CloseLabel);
   
   IndicatorShortName(IndicatorName);
   return (0);
}

int deinit() {
   return (0);
}



int start() {
   if (MaxBars>Bars){
      MaxBars = Bars;
   }
   
   double SUM;
   double MVA;
   double ATR;
   string Candles;
   string OBOverlay;
   string OSOverlay;

   int CreatedObjects = WindowFind(IndicatorName);
   
   for (int i = 0; i < MaxBars; i++) {
      
      SUM = 0;
      for (int k = i; k < NumBars + i; k++) 
      {
         SUM += (High[k] + Low[k]) / 2.0;
         MVA = SUM / NumBars;
      }
      
      SUM = 0;
      for (k = i; k < NumBars + i; k++) {
         SUM += High[k] - Low[k];
         ATR = 0.2 * (SUM / NumBars);
      }
      
      HH[i] = (High[i] - MVA) / ATR;
      LL[i] = (Low[i] - MVA) / ATR;
      OO[i] = (Open[i] - MVA) / ATR;
      CC[i] = (Close[i] - MVA) / ATR;
     
     // Showing Alerts
      if(Alerts && i == 0){
      if(CC[i]>=OBLevel && time_alert!=Time[0]){
         ShowAlert("OverBought. "+ NormalizeDouble(CC[i],2));
         time_alert=Time[0];
     }
      if(CC[i]<=OSLevel && time_alert!=Time[0]){
         ShowAlert("OverSold. "+ NormalizeDouble(CC[i],2));
         time_alert=Time[0]; 
     
     } //Instant alert, only once per bar
     }
     
   }
   ObjectsDeleteAll(CreatedObjects);
   
   
   for (k = 0; k <= MaxBars; k++) {
      Candles = IndicatorName + " HL" + k;
      ObjectCreate(Candles, OBJ_TREND, CreatedObjects, Time[k], HH[k], Time[k], LL[k]);
      ObjectSet(Candles, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(Candles, OBJPROP_RAY, FALSE);
      ObjectSet(Candles, OBJPROP_WIDTH, CandleSize);
      ObjectSet(Candles, OBJPROP_SELECTABLE, FALSE);
      
      
      if(HH[k]>=OBLevel && HH[k] != EMPTY_VALUE){
         OBOverlay = IndicatorName + " OB" + k;
      ObjectCreate(OBOverlay, OBJ_TREND, CreatedObjects, Time[k], HH[k] , Time[k], OBLevel );
      ObjectSet(OBOverlay, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(OBOverlay, OBJPROP_RAY, FALSE);
      ObjectSet(OBOverlay, OBJPROP_WIDTH, CandleSize);
      ObjectSet(OBOverlay, OBJPROP_COLOR, OB);
      ObjectSet(OBOverlay, OBJPROP_SELECTABLE, FALSE);
      
      
      }
       
       if(LL[k]<=OSLevel && LL[k] != EMPTY_VALUE){
         OSOverlay = IndicatorName + " OS" + k;
      ObjectCreate(OSOverlay, OBJ_TREND, CreatedObjects, Time[k], LL[k] , Time[k], OSLevel );
      ObjectSet(OSOverlay, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(OSOverlay, OBJPROP_RAY, FALSE);
      ObjectSet(OSOverlay, OBJPROP_WIDTH, CandleSize);
      ObjectSet(OSOverlay, OBJPROP_COLOR, OS);
      ObjectSet(OSOverlay, OBJPROP_SELECTABLE, FALSE);
      
         
      }
      
      
      if (Open[k] <= Close[k]) {
         ObjectSet(Candles, OBJPROP_COLOR, Up);
         
      } else {
         ObjectSet(Candles, OBJPROP_COLOR, Down);
         
      }
      
     
      
   }
   
   
   if(EnableColoredLevelLine == true){
      string UplineName = IndicatorName +  " OB";
          
      ObjectCreate(UplineName, OBJ_HLINE, CreatedObjects, 0, OBLevel);
      ObjectSet(UplineName, OBJPROP_COLOR, UpColor);
      ObjectSet(UplineName, OBJPROP_SELECTABLE, FALSE);
   
      string DownlineName = IndicatorName +  " OS";  
      ObjectCreate(DownlineName, OBJ_HLINE, CreatedObjects, 0, OSLevel);
      ObjectSet(DownlineName, OBJPROP_COLOR, DownColor);
      ObjectSet(DownlineName, OBJPROP_SELECTABLE, FALSE);
   }

   if(EnablePriceLine == true){
      string PricelineName = IndicatorName +  " Price";
      ObjectCreate(PricelineName, OBJ_HLINE, CreatedObjects, 0, CC[0]);
      ObjectSet(PricelineName, OBJPROP_COLOR, PriceLineColor);
      ObjectSet(PricelineName, OBJPROP_SELECTABLE, FALSE);
   }
   
   return (0);
}
