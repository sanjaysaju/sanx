//+------------------------------------------------------------------+
//|                                              GUNA COMBINER 1.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2100, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//ATTENTION!!!
//NEVER FORGET TO ACTIVATE THE CID LOCK INDICATOR SECURITY KEY WHEN TESTING IT TO CUSTOMERS!!!!
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
bool COMPUTER_ID = false; // Activate Security Key !!!!
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//INDICATOR SECURITY KEY BY CID LOCK NEVER FORGET TO ACTIVATE WHEN TESTING TO CUSTOMERS!!!!
//ATTENTION!!
//============================================================================================================================================================
//demo DATA DA EXPIRAÇÃO                           // demo DATA DA EXPIRAÇÃO
bool use_demo= true; // FALSE  // TRUE            // TRUE ATIVA / FALSE DESATIVA EXPIRAÇÃO
string ExpiryDate= "2025.02.07 00:00:00";                   // DATA DA EXPIRAÇÃO
string expir_msg="GUNA COMBINER EXPIRED? CONTACT:@its_guna24"; // MENSAGEM DE AVISO QUANDO EXPIRAR
//============================================================================================================================================================
//NÚMERO DA CONTA MT4                              // NÚMERO DA CONTA MT4
bool use_acc_number= false ; // TRUE  // TRUE      // TRUE ATIVA / FALSE DESATIVA NÚMERO DE CONTA
long acc_number[]={16185485,16192565,11344966,12676002,239802,16217048};                        // NÚMERO DA CONTA
string acc_numb_msg="VERIFY ID!!! CONTACT:@its_guna24 !!!"; //ID
//+------------------------------------------------------------------+

#property description   "GUNA-Indicator All rights reserved ©"
#property copyright ""
#property link      ""
#property description "Updated day 18/06/2050"
#property description "======================================================="
#define UNIQUE_SIGNAL_FILE_NAME "UniqueSignalFlag.txt"  // Unique name of the file used to track signal times
#define UNIQUE_COOLDOWN_DURATION 20                     // Unique cooldown period in seconds


#property strict
//============================================================================================================================================================
#property indicator_chart_window
#property indicator_buffers 70
//============================================================================================================================================================
#include <WinUser32.mqh>

string KingBinaryIndicatorProtector[256];

#import "user32.dll"
int   RegisterWindowMessageA(string lpstring);
int   PostMessageA(int  hWnd,int  Msg,int  wParam,string lParam);
#import
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
#import "kernel32.dll"
int  FindFirstFileW(string Path, ushort &Answer[]);
bool FindNextFileW(int handle,  ushort &Answer[]);
bool FindClose(int handle);
#import



//============================================================================================================================================================
//============================================================================================================================================================
#import "Telegram4Mql.dll"
string TelegramSendText(string ApiKey, string ChatId, string ChatText);
string TelegramSendTextAsync(string apiKey, string chatId, string chatText);
string TelegramSendPhotoAsync(string apiKey, string chatId, string filePath, string caption = "");
#import

#import  "Wininet.dll"
int InternetOpenW(string, int, string, string, int);
int InternetConnectW(int, string, int, string, string, int, int, int);
int HttpOpenRequestW(int, string, string, int, string, int, string, int);
int InternetOpenUrlW(int, string, string, int, int, int);
int InternetReadFile(int, uchar & arr[], int, int& OneInt[]);
int InternetCloseHandle(int);
bool HttpSendRequestW(int, string, int, string, int);
#import

#import "Kernel32.dll"
   bool GetVolumeInformationW(string,string,uint,uint&[],uint,uint,string,uint);
   #import
//============================================================================================================================================================
//CORRETORAS DISPONÍVEIS
enum corretora_price_pro
  {
   EmTodas = 1,    //Todas
   EmIQOption = 2, //IQ Option
   EmSpectre = 3,  //Spectre
   EmBinary = 4,   //Binary
   EmGC = 5,       //Grand Capital
   EmBinomo = 6,   //Binomo
   EmOlymp = 7     //Olymp Trade
  };
//============================================================================================================================================================
enum broker
  {
   Todos = 0,   //Todas
   IQOption = 1,
   Binary = 2,
   Spectre = 3,
   Alpari = 4,
   InstaBinary = 5
  };
//============================================================================================================================================================
enum corretora
  {
   Todas = 0,   //Todas
   IQ = 1,      //IQ Option
   Bin = 2,     //Binary
   Spectree = 3,//Spectre
   GC = 4,      //Grand Capital
   Binomo = 5,  //Binomo
   Olymp = 6    //Olymp Trade
  };
//============================================================================================================================================================
enum sinal
  {
   MESMA_VELA = 0,  //SAME CANDLE
   PROXIMA_VELA = 1 //NEXT CANDLE
  };
//============================================================================================================================================================
enum tipo_expiracao
  {
   TEMPO_FIXO = 0, //Fixed Time!
   RETRACAO = 1    //Time Frame Time!
  };
//============================================================================================================================================================
enum entrar
  {
   NO_TOQUE = 0,    //NO TOQUE
   FIM_DA_VELA = 1  //FIM DA VELA
  };
//============================================================================================================================================================
enum modo
  {
   MELHOR_PAYOUT = 'M', //MELHOR PAYOUT
   BINARIAS = 'B',      //BINARIAS
   DIGITAIS = 'D'       //DIGITAIS
  };
//============================================================================================================================================================
enum instrument
  {
   DoBotPro= 3, //DO BOT PRO
   Binaria= 0,  //BINARIA
   Digital = 1, //DIGITAL
   MaiorPay =2  //MAIOR PAYOUT
  }; 
//============================================================================================================================================================
enum signaltype
  {
   IntraBar = 0,          // SAME CANDLE
   ClosedCandle = 1       // NEXT CANDLE
  };
//============================================================================================================================================================
enum martintype
  {
   NoMartingale = 0,             // Sem Martingale (No Martingale)
   OnNextExpiry = 1,             // Próxima Expiração (Next Expiry)
   OnNextSignal = 2,             // Próximo Sinal (Next Signal)
   Anti_OnNextExpiry = 3,        // Anti-/ Próxima Expiração (Next Expiry)
   Anti_OnNextSignal = 4,        // Anti-/ Próximo Sinal (Next Signal)
   OnNextSignal_Global = 5,      // Próximo Sinal (Next Signal) (Global)
   Anti_OnNextSignal_Global = 6  // Anti-/ Próximo Sinal (Global)
  };
//============================================================================================================================================================
enum FiltroEma
  {
   EMA  = 1,  // EMA
   SMMA = 2,  // SMMA
   LWMA = 3,  // LWMA
   LSMA = 4   // LSMA SMA
  };
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
enum GUNAChave
  {
   disabled=0, //disabled off
   activate=1     //activate on
  };
enum intervalo
  {
   Cinco = PERIOD_M5,        // 5 MINUTES
   Quinze = PERIOD_M15,      // 15 MINUTES
   Trinta = PERIOD_M30,      // 30 MINUTES
   Uma_Hora = PERIOD_H1,     // 1 HOUR
  };
//============================================================================================================================================================
enum antloss
  {
   off   = 0,  //NÃO
   gale1 = 1  //ENTRAR APOS VELA
  };

enum extensaoROBO
  {
   csv   = 0,  //CSV
   txt = 1  //TXT
  };

enum automtizadores
  {
   DesligarRobo   = 0,  //OFF
   //OperarComBotCopy   = 1,  //BOT EM NUVEM (RECOMENDANDO)
   OperarComMX2 = 2,  //MX2 
 //  OperarComBOTPRO   = 3,  //BOTPRO
   OperarComPricePro = 4,  //PRICE
   OperarComTOPWIN   = 5,  //TOPWIN V4
   OperarComTOPWIN_ATUAL   = 9,  //TOPWIN V6 
   OperarComFrankestain = 6,  //RETORNO
   OperarComMT2 = 7,  //MT2
  // OperarComB2IQ = 8  //B2IQ
  };

enum simnao
  {
   DEACTIVATE = 0, //NO
   ACTIVATE = 1  //YES
  };
enum MODO_IONO_PRO
  {
   MUITOAGRESSIVO  = 60,        //VERY AGRESSIVE
   AGRESSIVO  = 150,              //AGRESSIVE
   MODERADO   = 250,                   //MODERATE
   CONSERVADOR   = 300            //CONSERVATIVE
  };
enum tipo
  {
   DESATIVAR_PRE_ALERTA, //DISABLE
   ATIVAR_PRE_ALERTA //ACTIVATE
  };
  enum enPrices
  {
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Média (alta+baixa+abertura+fechamento)/4
   pr_medianb,    // Corpo mediano médio (aberto+fechado)/2
   pr_tbiased,    // Preço tendencioso
   pr_tbiased2,   // Preço tendencioso (extremo)
   pr_haclose,    // Heiken ashi perto
   pr_haopen,     // Heiken ashi aberto
   pr_hahigh,     // Heiken ashi alto
   pr_halow,      // Heiken ashi baixo
   pr_hamedian,   // Heiken ashi mediana
   pr_hatypical,  // Heiken ashi típico
   pr_haweighted, // Heiken ashi ponderado
   pr_haaverage,  // Média de Heiken ashi
   pr_hamedianb,  // Corpo mediano Heiken ashi
   pr_hatbiased,  // Preço tendencioso da tendência Heiken ashi
   pr_hatbiased2  // Preço tendencioso (extremo) da tendência Heiken ashi
  };
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
enum enCalcType
  {
   st_atr, // Use atr
   st_ste, // Usar erro padrão
   st_sam, // Desvio padrão personalizado - com correção de amostra
   st_nos  // Desvio padrão personalizado - sem correção de amostra
  };
  enum donforextype{
dontouch,   //TOUCH ZONE ONLY
donbreak,   //BREAK ZONE
doninside,   //INSIDE ZONE
dontouchinside, //TOUCH OR INSIDE ZONE
donbreakinside //BREAK OR INSIDE ZONE
};
  enum UTCOffset
{
   UTCp600 = 0,         // UTC: +6:00 G.M.T
   UTCp530 = -1800,     // UTC: +5:30 G.M.T
   UTCp500 = -3600,     // UTC: +5:00 G.M.T
   UTCp430 = -5400,     // UTC: +4:30 G.M.T
   UTCp400 = -7200,     // UTC: +4:00 G.M.T
   UTCp330 = -9000,     // UTC: +3:30 G.M.T
   UTCp300 = -10800,    // UTC: +3:00 G.M.T
   UTCp200 = -14400,    // UTC: +2:00 G.M.T
   UTCp100 = -18000,    // UTC: +1:00 G.M.T
   UTC0000 = -21600,    // UTC: +0:00 G.M.T
   UTCm100 = -25200,    // UTC: -1:00 G.M.T
   UTCm200 = -28800,    // UTC: -2:00 G.M.T
   UTCm300 = -32400,    // UTC: -3:00 G.M.T
   UTCm330 = -34200,    // UTC: -3:30 G.M.T
   UTCm400 = -36000,    // UTC: -4:00 G.M.T
   UTCm500 = -39600,    // UTC: -5:00 G.M.T
   UTCm600 = -43200,    // UTC: -6:00 G.M.T
   UTCm700 = -46800,    // UTC: -7:00 G.M.T
   UTCm800 = -50400,    // UTC: -8:00 G.M.T
   UTCm900 = -54000,    // UTC: -9:00 G.M.T
   UTCm1000 = -57600,   // UTC: -10:00 G.M.T
   UTCm1100 = -61200,   // UTC: -11:00 G.M.T
   UTCm1200 = -64800    // UTC: -12:00 G.M.T
};
  enum signal
  {
   FLOW = 0,  //FLOW SIGNAL
   REVERSE = 1 //REVERSE SIGNAL
  };
  enum signaltel
{
multiplesignal,   //MULTIPLE SIGNAL SENT
singlesignal       //ONE SIGNAL SENT
};
//============================================================================================================================================================
datetime timet;
//============================================================================================================================================================
//============================================================================================================================================================
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                  DEFINIÇÃO DOS TRADES                           |
//+------------------------------------------------------------------+
static bool comment_chart_resolution = false;

//============================================================================================================================================================
input string  __________SETTINGS_______________________ = "====== SETTINGS! ==================================================================================================";//=================================================================================";
input simnao  AtivaPainel     = true;           // ACTIVATE PANEL
input int    Velas    = 200;            // BACKTEST CANDLE
input signal DirectionSignal =REVERSE;   //Signal Direction
input UTCOffset UTCCHNAGE=UTCp600;  //UTC TIME?
input signaltel GLOBALINTERVAL=multiplesignal;  //Global Interval?
input int    SecEnvio = 2;              // SECONDS BEFORE SENDING / ANTIDELAY
extern tipo           Entrada = ATIVAR_PRE_ALERTA; //USE ANTIDELAY / PRE ALERT
input simnao   AlertsMessage    = true;    // SEND ALERT
input simnao  Antiloss = false;            // ENTER AFTER LOSS
bool assinatura = false;          // Ver sua expiração de assinatura ?
 simnao  mostrarID = false; //Mostrar ID p/ automatizar @GUNAIQBotz
 input string  _________BCDESIGN___________________ = "=======BACKGROUND DESIGN==============================================================================";//=================================================================================";
static string emp1 = "///////////////////////////////////////";
input simnao use_main_window_image = false;  //BACKGROUND IMAGE?
extern string NAME_OF_YOUR_BMP_FILE = "";  //BMP FILE NAME?
input  int X_shift = 0; //IMAGE RIGHTSIDE SHIFT
input int Y_shift = 0;  //IMAGE DOWNSIDE SHIFT
static bool use_sub_window_image = false;
static string Name_bmp_image_SW = "gree3";

static string emp2 = "///////////////////////////////////////";
static bool show_periods_separator = false;
static color separator_period_color = clrGray;
static int separator_period_width = 0;
static ENUM_LINE_STYLE separator_period_style = STYLE_DOT;

string label_name1="sfscr7qw";
string separ_line_name="dfdfh6r";
int separator_period;
int prevbars;

input simnao BGT = true;       //BACKGORUND TEXT
extern string BT="";    //WRITE BACKGROUND TEXT
input  int X_shiftb = 400; //TEXT RIGHTSIDE SHIFT
input int Y_shiftb = 300;  //TEXT DOWNSIDE SHIFT
//============================================================================================================================================================
input string _________GUNA_STRATEGY100_____________= ""; //                                                                      //
input string _________GUNA_STRATEGY99_____________= "======| GUNA STRATEGIES |==========================================================================================="; //========| GUNA TRADER |====================                              //
input string _________GUNA_STRATEGY98_____________= ""; //                                                                      //
input string _________GUNA_STRATEGY1_____________= "=======| GUNA STRATEGY 1 |======================================================================"; //=================================================================================";
input simnao strategy1_Enabled = false;  //GUNA STRATEGY 1 
input string _________GUNA_STRATEGY2_____________= "=======| GUNA STRATEGY 2 |======================================================================"; //=================================================================================";
input simnao   KEN_Enabled   = false; //GUNA STRATEGY 2 
input string _________GUNA_STRATEGY3_____________= "=======| GUNA STRATEGY 3 |======================================================================"; //=================================================================================";
input simnao candlestrtegy  = false;                  // GUNA CANDLE STRATEGY 3
input string _________GUNA_STRATEGY4_____________= "=======| GUNA STRATEGY 4 |======================================================================"; //=================================================================================";
input simnao Pulback_Enabled  = false;                 //GUNA PULLBACK STRATEGY 4 
input string _________GUNA_STRATEGY85_____________= "=======| GUNA STRATEGY 5 |======================================================================"; //=================================================================================";
input simnao fdbag = false; // GUNA EXTREME STRATEGY 
input string _________GUNA_STRATEGY6_____________= "=======| GUNA STRATEGY 6 |======================================================================"; //=================================================================================";
input simnao   secret    = false;          // GUNA TIME-TURN STRATEGY 6 
input string _________GUNA_STRATEGY7_____________= "=======| GUNA STRATEGY 7 |======================================================================"; //=================================================================================";
input simnao   FLOW = false;                    // GUNA FLOW STRATEGY 7 
input string _________GUNA_STRATEGY8_____________= "=======| GUNA STRATEGY 8 |======================================================================"; //=================================================================================";
input simnao Reversal_Enabled = false; // GUNA REVERSAL STRATEGY 8 
input string  __________PRICEACTION_______________________ = "==== GUNA PRICE ACTION! ==================================================================================================";//=================================================================================";
input simnao   priceaction  = false;         // GUNA PRICE ACTION 
input string _________GUNA_STRATEGY9_____________= "=======| GUNA STRATEGY 9 |======================================================================"; //=================================================================================";
input simnao  strategy9_Enabled = false; //GUNA STRATEGY 9 
input string _________GUNA_STRATEGY10_____________= "=======| GUNA STRATEGY 10 |======================================================================"; //=================================================================================";
input simnao   HUNTER_Enabled  = false; //GUNA HUNTER STRATEGY 
input string _________GUNA_STRATEGY11_____________= "=======| GUNA STRATEGY 11 |======================================================================"; //=================================================================================";
input simnao    KILLER_Enabled = false; //GUNA KILLER STRTEGY 
input string _________GUNA_STRATEGY12_____________= "=======| GUNA STRATEGY 12 |======================================================================"; //=================================================================================";
input simnao    BERSERK = false; //BERSERK STRATEGY 
input string _________GUNA_STRATEGY13_____________= "=======| GUNA STRATEGY 13 |======================================================================"; //=================================================================================";
input simnao    hulk_Enabled = false; //HULK STRATEGY 
input string _________GUNA_STRATEGY14_____________= "=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
input simnao    professor_Enabled = false; //PROFESSOR STRATEGY 
input string _________GUNA_STRATEGY15_____________= "=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
input simnao    beast_Enabled = false; //BEAST STRATEGY
input string _________GUNA_STRATEGY16_____________= "=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
input simnao sniper_Enabled = false; //SNIPER STRATEGY
input string _________GUNA_STRATEGY17_____________= "=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
input simnao ninja_Enabled = false; // NINJA STRATEGY
input string _________GUNA_STRATEGY18_____________= "=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
input simnao hacker_Enabled = false; // HACKER STRATEGY
input string _________GUNA_STRATEGY19_____________= "=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
input simnao shadow = false;   // SHADOW STRATEGY
input string ___Elite_strategy_____ ="=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
input simnao Elite_Enabled = false; // ELITE STRATEGY
input string _________GUNA_STRATEGY5_____________= "=======| GUNA STRATEGY 5 |======================================================================"; //=================================================================================";
input simnao   EXTREME   = true;         // GUNA SECRET STRATEGY  
input string ___Elitbbe_strategy_____ ="=======| GUNA STRATEGY 14 |======================================================================"; //=================================================================================";
extern  simnao               SNRG                 = false;                             // SNR STRATEGY
extern MODO_IONO_PRO         TF                   = MUITOAGRESSIVO;                     // MODE
//+------------------------------------------------------------------+
//|                    ESTRETAGTIA_DRAGON                            |
//+------------------------------------------------------------------+
input string _________RSI_STRATEGY_____________= "=======| BERSERK STRATEGY |======================================================================"; //=================================================================================";
input simnao    GUNAEstrategia               = false;  //BERSERK STRATEGY
input int PeriodoRSI = 3;                             //PERIOD RSI
input int MaxRSI = 60;                                //MAXIMUM RSI
input int MinRSI = 30;                               //MINIMUM RSI
input string _________GUNA_STRATEGY101_____________= ""; //                                                                      //
input string _________GUNA_STRATEGY97_____________= "======| GUNA STRATEGIES |==========================================================================================="; //========| GUNA TRADER |====================                              //
input string _________GUNA_STRATEGY96_____________= ""; //                                                                       //
//+------------------------------------------------------------------+
//|                    VALUECHART                           |
//+------------------------------------------------------------------+
input string _________VALUECHART_____________= "=======| VALUE CHART |======================================================================"; //=================================================================================";
extern simnao   Value_Enabled = false; //VALUE CHART
extern int NumBars = 5; //PERIOD 
extern double VC_MAX = 8.0; // MAXIMUM
extern double VC_MIN = -8.0; // MINIMUM         
//+------------------------------------------------------------------+
//|                        MÃO FIXA                               |
//+------------------------------------------------------------------+
input string  _________OperationalBAND___________________ = "====== FasTMA LINE ==================================================================================================";//=================================================================================";
input simnao           BAND =false;                 //FAS TMA LINE
extern int               HalfLength   = 10;           // Half-Length
input enPrices           Price        = pr_close;     // Price
input int                period       = 20;           // Period
input double             Multiplier   = 2.0;          // Multiplier
input enCalcType         Type         = st_atr;       // Calculate Type
input int                DevLookBack  = 10;           // Deviation look-back period
input int                bandshift    =1;             //Shift
input    simnao          bandcolour=true;                        //Band Colour                                                   //            
//+------------------------------------------------------------------+
//|                    BOLLINGAR_BAND                            |
//+------------------------------------------------------------------+
input string  __________BOLLINGARBAND_______________________ = "========| BOLLINGARBAND |==================================================================================================";//=================================================================================";
ENUM_TIMEFRAMES STCTimeFrame = PERIOD_CURRENT; //TimeFrame
extern simnao              BB_Enabled = DEACTIVATE; // BOLLINGAR BAND
extern int                BB_Period=20;// PERIOD
input double             BB_Deviations=2.0;//DEVIATION
extern int                BB_Shift=1;//SHIFT
extern ENUM_APPLIED_PRICE  BB_Price =PRICE_CLOSE;//PRICE
ENUM_TIMEFRAMES BBTimeFrame = PERIOD_CURRENT; //TimeFrame
//============================================================================================================================================================
input string  _________RSISTRATEGY___________________ = "========| RSI+SR STRATEGY |================================================================================";//=================================================================================";
extern simnao RSI_Enabled          = false; //RSI STRATEGY(RSI+SR)
extern int    RSI_Period           =3; //PERIOD
extern int    RSI_MAX              =70; //RSI MAX
extern int    RSI_MIN              =30; //RSI MIN
 ENUM_APPLIED_PRICE RSI_Price      =PRICE_CLOSE;//PRICE
ENUM_TIMEFRAMES RSITimeFrame = PERIOD_CURRENT; //TIMEFRAME

//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    STOCHASTIC                            |
//+------------------------------------------------------------------+
input string  __________STOCHASTIC_______________________ = "=========| STOCHASTIC |==================================================================================================";//=================================================================================";
extern simnao SO_Enabled = DEACTIVATE; // STOCHASTIC
extern int                SO_KPeriod=5; // %K PERIOD
extern int                SO_DPeriod=3; // %D PERIOD
extern int                SO_Slowing=3; // SLOW
extern ENUM_MA_METHOD     SO_Mode=MODE_SMA;
extern ENUM_STO_PRICE     SO_Price=STO_CLOSECLOSE;
extern int                SO_MAX=80; // MAXIMUM LEVEL
extern int                SO_MIN=20; // MINIMUM LEVEL 
//+------------------------------------------------------------------+
//|                    VOLUE CHART  vs   RSI                         |
//+------------------------------------------------------------------+
input string  _________OperationalEMA___________________ = "=====| EMA CROSS STRATEGY | ================================================================================";//=================================================================================";
input simnao AtivarCruzamento = false;    //EMA CROSS STRTEGY ?
input int FasterEMA = 1;                // RAPID EMA 
input int SlowerEMA = 5;                // SLOW EMA 
//============================================================================================================================================================
input string  _________OperationalRVI___________________ = "========| RVI FILTER STRATEGY |================================================================================";//=================================================================================";
input simnao  EnabledRVI  = false;  //STRATEGY RVI ?
input int PERIODORVI = 10;         //PERIOD RVI 
input int Linha = 1;              //0 = RVI LINE, 1 = SIGNAL LINE
input double MAXRVI = 0.1;        //MAXIMUM RVI 
input double MINRVI = -0.1;       //MINIMUM RVI 
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    VOLUE CHART  vs   RSI                         |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string  _________OperationalMFI___________________ = "========| MFI FILTER STRATEGY |================================================================================";//=================================================================================";
input simnao   EnabledMFI = false; //STRATEGY MFI?
input int PERIODOMFI = 3;        //PERIOD MFI 
input ENUM_APPLIED_PRICE  mfiPrice   = PRICE_CLOSE; // INPUT MODULE
input int MAXMFI = 95;           //MAXIMUM MFI 
input int MINMFI = 5;            //MINIMUM MFI 
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    VOLUE CHART  vs   RSI                         |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string  _________OperationalWPR___________________ = "========| WPR FILTER STRATEGY |================================================================================";//=================================================================================";
input simnao  EnabledWPR  = false; //STRATEGY WPR  ?
input int PERIODOWPR = 1;        //PERIOD WPR 
input ENUM_APPLIED_PRICE  wprPrice   = PRICE_CLOSE; // INPUT MODULE
input int MAXWPR = -95;          //MAXIMUM WPR 
input int MINWPR = -5;           //MINIMUM WPR 
//============================================================================================================================================================
input string  _________MACDSTRATEGY___________________ = "========| MACD STRATEGY |================================================================================";//=================================================================================";
extern simnao AtivarMACD = false; // MACD Strategy ?
extern int MACD_Period1 = 12; // MACD PERIOD 1 
extern int MACD_Period2 = 26; // MACD PERIOD 2 
extern int MACD_Period3 = 9;  // MACD PERIOD 3 
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    ESTRETAGTIA_DRAGON_1                          |
//+------------------------------------------------------------------+
input string _________CANDLE_CONFIRMATION_____________= "=======| CANDLE RESPECT |======================================================================"; //=================================================================================";
input simnao    GUNAEstrategia1               = false;  //CANDLE RESPECT(RSI+SR+CANDLE)
input int PeriodoRSI1 = 3;                             //PERIOD RSI
input int MaxRSI1 = 90;                                //MAXIMUM RSI
input int MinRSI1 = 10;                               //MINIMUM RSI
//+------------------------------------------------------------------+
//|                   SUPORTE_E_RESISTENCIA                          |
//+------------------------------------------------------------------+
input string  ________SUPPORT_AND_RESISTANCE___________________ = "====| SUPPORT AND RESISTANCE |================================================================================";//=================================================================================";
input simnao  SeR                = false;  // SUPPORT AND RESSISTENT
input int mediaMovel = 14; //MEDIA MOVEL
 int mediaMovel2 = 30; //Periodo Segunda Media Movel
 simnao MostrarLinha = false; //Mostrar Marcação SeR
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    AtivaDonchian                                     |
//+------------------------------------------------------------------+
input string  ________DONCHIAN___________________ = "=======| DONCHAIN STRATEGY |================================================================================";//=================================================================================";
input simnao AtivaDonchian = DEACTIVATE; //ACTIVATE DONCHAIN
input int       Periods=15; //PERIODS
input int       Extremes=3; //EXTREMES
input int       Margins=-2; //MARGINS
input int       Advance=0; //ADVANCE
input int LarguraDonchian = 2; //LINE WIDTH
input ENUM_LINE_STYLE EstiloDonChian = STYLE_SOLID; //LINE STYLE
input color CorDonChianAcima = clrGreen; //TOP LINE COLOUR
input color CorDonChianAbaixo = clrRed; //BOTTOM LINE COLOUR
//============================================================================================================================================================input string  ________SeR___________________ = "=== SUPORTE E RESITENCIA ================================================================================";//=================================================================================";
//+------------------------------------------------------------------+
//|                    CCI                                           |
//+------------------------------------------------------------------+
input string  ________CCI___________________ = "=======| CCI STRATEGY |================================================================================";//=================================================================================";
input simnao Cci_Enabled  = DEACTIVATE;// ACTIVATE CCI
input int                   CCI_Period               = 6;                     // PERIOD
input ENUM_APPLIED_PRICE    Apply_to                 = PRICE_TYPICAL;         // PRICE
input int                   CCI_Overbought_Level     = 160;                   // MAXIMUM LEVEL
input int                   CCI_Oversold_Level       = -160;                  //MINIMUM LEVEL
//============================================================================================================================================================input string  ________SeR___________________ = "=== SUPORTE E RESITENCIA ================================================================================";//=================================================================================";
//+------------------------------------------------------------------+
//|                    ADX                                           |
//+------------------------------------------------------------------+
input string  ________ADX___________________ = "=======| ADX STRATEGY |================================================================================";//=================================================================================";
input simnao             Adx_Enabled  = DEACTIVATE;                  // ACTIVATE ADX
input int                period_adx   = 14;                  // PERIOD
input double             level_adx    = 60.0;                 // LEVEL
input ENUM_APPLIED_PRICE price_adx    = 0;                   // PRICE
//============================================================================================================================================================input string  ________SeR___________________ = "=== SUPORTE E RESITENCIA ================================================================================";//=================================================================================";
//============================================================================================================================================================input string  ________SeR___________________ = "=== SUPORTE E RESITENCIA ================================================================================";//=================================================================================";
//+------------------------------------------------------------------+
//|                    DON_FOREX                                     |
//+------------------------------------------------------------------+
input string  ________DON_FOREX___________________ = "======= DONFOREX ================================================================================";//=================================================================================";
input simnao ativar_donforex = false; //Donforex
input int min_size_donforex = 0; //Min. Area for donforex signals
input donforextype donforexind=dontouchinside;   //Operate on?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    P_SAR                                     |
//+------------------------------------------------------------------+
input string  ________PSAR___________________ = "======= PARABOIC SAR ================================================================================";//=================================================================================";
input simnao UsePSAR = false;            // PARABOLIC SAR
input double PSAR_Step = 0.02;        // STEP VALUE
input double PSAR_Maximum = 0.2;      // MAXIMUM VALUE
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                   FILTRO_DE_TENDENCIA                            |
//+------------------------------------------------------------------+
input string  ________TREND_FILTER___________________ = "=======| TREND FILTER |================================================================================";//=================================================================================";
input simnao              Filtro_Tendencia               = false;                       // TREND FILTER
input int gi_84 = 20; //PERIOD
input double gd_88 = 0 ; //SHIFT
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                   FILTRO_DE_RETRAÇÃO                             |
//+------------------------------------------------------------------+
input string  ________RETRACTION_FILTER___________________ = "=======| RETRACTION FILTER |================================================================================";//=================================================================================";
input simnao              FILT_RET_              = false;                             // RETRACTION FILTER
input int                GUNARatio           =60;                               // BODY x WICK [%]
//============================================================================================================================================================input string  ________SeR___________________ = "=== SUPORTE E RESITENCIA ================================================================================";//=================================================================================";
//+------------------------------------------------------------------+
//|                    INDICADOR_EXTERNO_1                           |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string ___________EXTERNAL_INDICATOR_1_____________= "========= EXTERNAL INDICATOR  ======================================================================"; //=================================================================================";
input simnao COMBINER = true;         // ACTIVATE THIS INDICATOR ?
input string IndicatorName = "TS SK";     // INDICATOR NAME ?
input int IndiBufferCall = 2;        // BUFFER CALL ?
input int IndiBufferPut = 3;         // BUFFER PUT ?
input signaltype SignalType = IntraBar;    // ENTRY TYPE ?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    INDICADOR_EXTERNO_2                           |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string ___________EXTERNAL_INDICATOR_2_____________= "======= EXTERNAL INDICATOR 2! ======================================================================"; //=================================================================================";
input simnao COMBINER2 = false;         // ACTIVATE THIS INDICATOR?
input string IndicatorName2 = "auto-trend-lines-channels-indicator";     // INDICATOR NAME ?
input int IndiBufferCall2= 0;        // BUFFER CALL ?
input int IndiBufferPut2 = 1;         // BUFFER PUT ?
input signaltype SignalType2 = IntraBar;    // ENTRY TYPE ?
//+------------------------------------------------------------------+
//|                    INDICADOR_EXTERNO_3                           |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string ___________EXTERNAL_INDICATOR_3_____________= "====== EXTERNAL INDICATOR 3!  ======================================================================"; //=================================================================================";
input simnao COMBINER3 = false;         // ACTIVATE THIS INDICATOR?
input string IndicatorName3 = "";     //INDICATOR NAME ?
input int IndiBufferCall3= 0;        // BUFFER CALL ?
input int IndiBufferPut3 = 1;         // BUFFER PUT ?
input signaltype SignalType3 = IntraBar;    // ENTRY TYPE ?
//+------------------------------------------------------------------+
//|                    INDICADOR_EXTERNO_4                           |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string ___________EXTERNAL_INDICATOR_4_____________= "====== EXTERNAL INDICATOR 4!  ======================================================================"; //=================================================================================";
input simnao COMBINER4 = false;         // ACTIVATE THIS INDICATOR?
input string IndicatorName4 = "";     // INDICATOR NAME ?
input int IndiBufferCall4= 0;        // BUFFER CALL ?
input int IndiBufferPut4 = 1;         // BUFFER PUT ?
input signaltype SignalType4 = IntraBar;    // ENTRY TYPE ?
//============================================================================================================================================================
input string  __________TIME_FILTER_______________________ = "====== TIME FILTER! ==================================================================================================";//=================================================================================";
input simnao           filtro_horario = false;                                //ACTIVATE FILTER
input string         horario_inicio_sinais = "00:00";                     //START TIME
input string         horario_fim_sinais = "16:00";                        //END TIME
input string         horario_inicio_sinais3 = "21:00";                     //START TIME
input string         horario_fim_sinais3 = "23:59";                        //END TIME
//============================================================================================================================================================
//============================================================================================================================================================
input string  __________NEWS_FILTER_______________________ = "====== NEWS_FILTER! ==================================================================================================";//=================================================================================";
input simnao           filtro_noticias = false; // ACTIVATE NEWS ?
input int            noticia_minutos_antes = 15;  // MIN AFTER
input int            noticia_minutos_depois = 15; //MIN BEFORE
input int            noticia_impacto = 3; // IMPACT LEVEL
input simnao alerta_noticia_touros = ACTIVATE; //VIEW NEWS ALERT
//============================================================================================================================================================
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                        MÃO FIXA                               |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string  _________ACERTIVITY_FILTER___________________ = "====== ACERTIVITY FILTER ================================================================================";//=================================================================================";
input simnao Mãofixa            = false;    // FILTER WITH NON MARTINGALE
input double FiltroMãofixa = 65;        // WINRATE WITH NON MARTINGALE
input simnao AplicaFiltroNoGale = false;    // FILTER WITH MARTINGALE 1
input double FiltroMartingale = 80;     // WINRATE WITH MARTINGALE 1
//============================================================================================================================================================
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                      FILTRO ANÁLISE                              |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string  _________ANALYSIS_FILTERS___________________ = "======= ANALYSIS FILTERS! ================================================================================";//=================================================================================";
static simnao  noDellArrow_ = true; //INTERVAL ?
input int Intervalo = 5;                  // INTERVAL BETWEEN ORDER ?
input simnao   AtivarTamanhoVela = false; //MINIMUM PIPS
extern int MinPips   = 400; // BLOCK BIGGER CANDLE PIPS
input simnao   AtivarTamanhoVela1 = false; //MAXIMUM PIPS
extern int maxPips   = 0; // BLOCK SMALLER CANDLE PIPS
input simnao Bloquea = false;               // BLOCK SAME COLOR ENTRY OF CANDLE ?
input int quantidade = 3;                 // NUMBER OF CANDLES ?
input simnao    FiltroVelas     = false;    // USE CANDLE FILTER ?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                 CONCTOR  MT2  price                             |
//+------------------------------------------------------------------+
//============================================================================================================================================================
input string _____________AUTOMIZERS____________________ = "====== AUTOMIZERS =================================================================================";//=================================================================================";
bool   ModoOTC = true;                            //Enviar sinal em OTC ?
input automtizadores UsarRobo = DesligarRobo; //AUTO TRADE
input int    ExpiryMinute = 0;                         //EXPIRATION TIME (0 = AUTO)
input string SignalName_ ="GUNA";     //SIGNAL NAME FOR ROBOT (Optional)
input string ____________MX2____________________ = "====== MX2 =================================================================================";
input tipo_expiracao TipoExpiracao = RETRACAO;          //INPUT TYPE ON MX2  ?
 string ____________B2IQ____________________ = "====== B2IQ =================================================================================";
 string vps = "";                                  //IP:PORTA da VPS (caso utilize B2IQ) ?input string ____________MX2____________________ = "====== MX2 =================================================================================";
input string ____________MT2____________________ = "====== MT2 =================================================================================";
input martintype MartingaleType = OnNextExpiry;         //MARTINGALE (MT2) ?
input double MartingaleCoef = 2.3;                      //MARTINGALE COEFFICIENT ?
input int    MartingaleSteps = 1;                       //MARTINGALE FOR MT2 ?
input double TradeAmount = 2;                           //TRADE AMOUNT FOR MT2 ?
input string _____RETURN_FILE_EXTENSION____________________ = "==== RETURN FILE EXTENSION =================================================================================";
input extensaoROBO ExtensaoBot = csv; //FINAL RESULT
//============================================================================================================================================================
input string ______Telegram_settings____________________ = "====== SEND TELEGRAM SIGNAL =================================================================================";
input simnao enviar_telegram = true; //SEND SIGNAL TO TELEGRAM
input simnao sendphoto = false; // SEND SIGNAL SCREENSHOOT TO TG
input simnao sendphotor = false; // SEND RESULT SCREENSHOOT TO TG
input simnao clearfull=false;//CLEAR SCREENSHOT
input string nome_sala       = "MONEY";//NAME OF YOUR ROOM
input string nome_payment       = "";//CHECK PAYMENT LINK
input string nome_contact       = "";//CHECK CONTACT INFORMATION
input string  apikey_ = "";                      //API KEY TOKEN
input string chatid = "";                       //CHAT ID CHANNEL
input simnao ATpropaganda_ = true; //ACTIVATE ADVERTISING
input string progandaTexto_ = "TELEGRAM:"; //ADVERTISING TEXT
static string msgWin = ""; //MESSAGE WIN
static string msgLoss = "";//MESSAGE LOSS
input simnao mostrarResultadoFechamento = true; //SHOW RESULT STATISTICS
input simnao resultados_parciais_ao_vivo = true; //SEND WIN AND LOSS RESULT
input int tempo_minutos_ao_vivo = 60; //TIME TO SEND FINAL RESULT  (MINUTES)
static string ______TUTORIAL_TELEGRAM____________________ = "Chame o @Copysinal_bot no telegram e de o comando /getid pra obter seu  Chat ID";
//============================================================================================================================================================

MqlDateTime timess;
string dirBot = "GUNATrader\\";
datetime temposs = TimeToStruct(TimeLocal(),timess);
string hoje = StringFormat("%d%02d%02d",timess.year,timess.mon,timess.day);



//datetime dataExpiracao = int(D'31.12.2021'); // AQUI VC SELECIONA QUANDO O INDICADOR VAI EXPIRAR



bool liberar_acesso = true;
#define READURL_BUFFER_SIZE   100
#define INTERNET_FLAG_NO_CACHE_WRITE 0x04000000
//VARIAVEIS TELEGRAM
string  arquivo_estatisticas = dirBot+hoje+"_results.txt";
bool assertividade_global = true;
#define CALL 1
#define PUT -1
datetime horario_expiracao[], horario_entrada[];
string horario_entrada_local[];
double entrada[];
double fasterEMAnow, slowerEMAnow, fasterEMAprevious, slowerEMAprevious, fasterEMAafter, slowerEMAafter;
int tipo_entrada[];
datetime befTime_signal, befTime_check, befTime_telegram, befTime_alert;
datetime befTime_aovivo=TimeGMT()-10800+tempo_minutos_ao_vivo*60;
//============================================================================================
//beast
int                   CCI4_Period               = 3;                     // Período
ENUM_APPLIED_PRICE    Apply_to4                 = PRICE_CLOSE;         // Preço
int                   CCI4_Overbought_Level     = 80;                   // Nível Máximo
int                   CCI4_Oversold_Level       = -80;                  //Nível Mínimo
int PERIODORVI4   = 2;
double MAXRVI4    = 0.4;
double MINRVI4    = -0.4;
int PERIODOWPR3   = 2;
int MAXWPR3       = -25;
int MINWPR3       = -75;
//============================================================================================================================================================
//KEN
int PeriodoRSI_2 = 2;
int MaxiRSI_2 = 85;
int MiniRSI_2 = 15;
int PERIODOCCI_2 = 4;
int MAXCCI_2 = 100;
int MINCCI_2 = -100;
//============================================================================================
//BERSERK
int PeriodoRSI_8 = 2;
int MaxRSI_8 = 85;
int MinRSI_8 = 15;
int                   CCI1_Period               = 6;                     // PERIOD
ENUM_APPLIED_PRICE    Apply_to1                 = PRICE_TYPICAL;         // PRICE
int                   CCI1_Overbought_Level     = 160;                   // MAXIMUM
int                   CCI1_Oversold_Level       = -160;                  //MINIMUM
//============================================================================================

//ninja

int                RSI1_Period=2; // Período
ENUM_APPLIED_PRICE RSI1_Price=PRICE_CLOSE;
int                RSI1_MAX=90; // Nível Máximo
int                RSI1_MIN=10; // Nível Mínimo
ENUM_TIMEFRAMES RSITimeFrame1 = PERIOD_CURRENT; //TimeFrame
int                RSI2_Period=5; // Período
ENUM_APPLIED_PRICE RSI2_Price=PRICE_CLOSE;
int                RSI2_MAX=60; // Nível Máximo
int                RSI2_MIN=30; // Nível Mínimo
ENUM_TIMEFRAMES RSITimeFrame2 = PERIOD_CURRENT; //TimeFrame
int                RSI3_Period=3; // Período
ENUM_APPLIED_PRICE RSI3_Price=PRICE_CLOSE;
int                RSI3_MAX=85; // Nível Máximo
int                RSI3_MIN=15; // Nível Mínimo
ENUM_TIMEFRAMES RSITimeFrame3 = PERIOD_CURRENT; //TimeFrame
//============================================================================================
//KILLER
int PeriodoRSI_7 = 2;
int MaxRSI_7 = 92;
int MinRSI_7 = 8;
//============================================================================================
//HUNTER
int PERIODOCCI0_3 = 3;
int MAXCCI_03 = 80;
int MINCCI_03 = -80;
int BB4_Period  = 20;
int BB4_Dev  = 2;
int BB4_Shift = 1;
//============================================================================================================================================================
//Estrategia price Extremo
int dist=40;
int hhb,llb;
int tvv;
bool tm=true;
//============================================================================================================================================================
//strategy1
int    BB_Period1               = 20;
double    BB_Dev1               = 2;
int    BB_Shift1                = 0;
ENUM_APPLIED_PRICE  Apply_to2   = PRICE_TYPICAL;
int PERIODOCCI_3 = 14;
int MAXCCI_3 = 100;
int MINCCI_3 = -100;
//============================================================================================================================================================
//Pulback
bool  UseSMAFilter  = false; //Média Móvel || Ativar/Desativar
int  MA_Period = 20; // Período
int  MA_Shift = 0; // MA Shift
ENUM_MA_METHOD MA_Method = MODE_EMA; // Tipo de Média
ENUM_APPLIED_PRICE    MA_Applied_Price  = PRICE_CLOSE; //Aplicar A
int FilterShift = 0; // MA Filtro Shift
int PeriodoRSI_6 = 3;
int MaxRSI_6 = 50;
int MinRSI_6 = 50;
//============================================================================================
//sniper
int                   CCI5_Period               = 6;                     // Período
ENUM_APPLIED_PRICE    Apply_to5                 = PRICE_TYPICAL;         // Preço
int                   CCI5_Overbought_Level     = 160;                   // Nível Máximo
int                   CCI5_Oversold_Level       = -160;                  //Nível Mínimo
int PERIODOWPR4   = 7;
int MAXWPR4       = -10;
int MINWPR4       = -90;
//============================================================================================
//hulk
int                   CCI2_Period               = 6;                     // Período
ENUM_APPLIED_PRICE    Apply_too2                 = PRICE_TYPICAL;         // Preço
int                   CCI2_Overbought_Level     = 120;                   // Nível Máximo
int                   CCI2_Oversold_Level       = -120;                  //Nível Mínimo
int PERIODORVI3   = 4; //Período
double MAXRVI3    = 0.2; //Nível Máximo
double MINRVI3    = -0.2; //Nível Mínimo
//============================================================================================
//hacker
int                   CCI6_Period               = 14;                     // Período
ENUM_APPLIED_PRICE    Apply_to6                 = PRICE_TYPICAL;         // Preço
int                   CCI6_Overbought_Level     = 100;                   // Nível Máximo
int                   CCI6_Oversold_Level       = -100;                  //Nível Mínimo
int    BB2_Period               = 15;//Período
double    BB2_Dev                  = 3;// Desvio
int    BB2_Shift                = 0;//Deslocar

int PeriodoRSI_10 = 3;
int MaxRSI_10 = 60;
int MinRSI_10 = 30;
int PeriodoRSI_11 = 2;
int MaxRSI_11 = 85;
int MinRSI_11 = 15;
int PeriodoRSI_12 = 2;
int MaxRSI_12 = 90;
int MinRSI_12 = 10;
//====================================================================================
// GUNA REVERSAL
int PeriodRSI_2 = 3;
int MaxRSI_2 = 85;
int MinRSI_2 = 15;
int PeriodoRSI_3 = 5;
int MaxRSI_3 = 60;
int MinRSI_3 = 35;
int PeriodoRSI_4 = 2;
int MaxRSI_4 = 90;
int MinRSI_4 = 10;
//============================================================================================
//professor
int                   CCI3_Period               = 4;                     // Período
ENUM_APPLIED_PRICE    Apply_to3                 = PRICE_TYPICAL;         // Preço
int                   CCI3_Overbought_Level     = 100;                   // Nível Máximo
int                   CCI3_Oversold_Level       = -100;                  //Nível Mínimo
int PeriodoRSI_9 = 3;
int MaxRSI_9 = 85;
int MinRSI_9 = 15;
//============================================================================================
//ESTRATÉGIAS
int PERIODRVI   = 2;
double MAXIRVI    = 0.3;
double MINIRVI    = -0.3;
int PERIODOWPR2   = 4;
int MAXWPR2       = -10;
int MINWPR2       = -90;
//============================================================================================================================================================
//FIM VARIAVEIS TELEGRAM
int ExpiryMinutes=ExpiryMinute == 0 ? _Period : ExpiryMinute;
string ExtensaoBots=ExtensaoBot == 0 ? "csv" : "txt";
//VARIAVEIS DE NOTICIAS
string horario_inicio_sinais2;
string horario_fim_sinais2;
//VARIAVEIS DE NOTICIAS
string horario_inicio_sinais4;
string horario_fim_sinais4;
//FIM DE VARIABEIS NOTICIAS
int tempoIntervalo = 60;
sinal SinalEntradaMX2 = MESMA_VELA;            //Entrar na ?
corretora CorretoraMx2 = Todas;                //Corretora ?
string paridade = Symbol()=="CRYIDZbnm" ? "Crypto IDX" : Symbol();

string SignalName = SignalName_;
string apikey = apikey_;
bool noDellArrow = noDellArrow_;
bool FILT_RET = FILT_RET_;
bool ATpropaganda = ATpropaganda_;
string propagandaTexto = ATpropaganda==true ? "\n"+progandaTexto_ : "";

double b4plusdi, b4minusdi, nowplusdi, nowminusdi;

//FILTRO DE NOTICIAS
datetime desativar_sinais_horario;

//DOMFOREX
double donforex = ativar_donforex==true ? iCustom(NULL,0,"DONFOREX",0,0) : 0;

int preAlerta = Entrada==ATIVAR_PRE_ALERTA ? clrWhite : clrNONE;

//MARCAÇÃO SUPORTE E RESISTENSIA
int mostrarSeR = MostrarLinha==true ? clrWhite : clrNONE;


//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                   CONCTOR  BOTPRO  price                        |
//+------------------------------------------------------------------+
//============================================================================================================================================================
string ____________BOTPRO________________ = "===== SIGNAL SETTINGS BOTPRO =================================================================================";//=================================================================================";
string NameOfSignal = SignalName;            // Nome do Sinal para BOTPRO ?
double TradeAmountBotPro = TradeAmount;
int MartingaleBotPro = MartingaleSteps;      //Coeficiente do Martingale ?
instrument Instrument = DoBotPro;            // Modalidade ?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|               CONCTOR  PRICE PRO  price                         |
//+------------------------------------------------------------------+
//============================================================================================================================================================
string ___________PRICEPRO_____________= "=== SIGNAL SETTINGS PRICE PRO ================================================================================="; //=================================================================================";
corretora_price_pro PriceProCorretora = EmTodas;       //Corretora ?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                 CONCTOR  B2IQ  price                            |
//+------------------------------------------------------------------+
//============================================================================================================================================================
string _____________B2IQ__________________ = "====== SIGNAL SETTINGS B2IQ =================================================================================";//=================================================================================";
sinal SinalEntrada = MESMA_VELA;           //Entrar na ?
modo Modalidade = MELHOR_PAYOUT;           //Modalidade ?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                    CONCTOR  MAGIC TRADER                         |
//+------------------------------------------------------------------+
//============================================================================================================================================================
string ________MAGIC_TRADER______________ = "===== SIGNAL SETTINGS MAGIC  ================================================================================="; //=================================================================================";
string               NomeIndicador        = SignalName;  // Nome do Sinal ?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                CONCTOR  SIGNAL SETTINGS MT2                      |
//+------------------------------------------------------------------+
//============================================================================================================================================================
string _____________MT2_____________= "======= SIGNAL SETTINGS MT2 ================================================================================="; //=================================================================================";
broker Broker = Todos;    //Corretora ?
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                CONCTOR  SIGNAL SETTINGS TOPWIN                   |
//+------------------------------------------------------------------+
//============================================================================================================================================================
string _____________TOP_WIN__________ = "===== CONFIGURAÇÕES TOP WIN =============================================================================================="; //=================================================================================";
string Nome_Sinal = SignalName;             // Nome do Sinal (Opcional)
sinal Momento_Entrada = MESMA_VELA;         // Vela de entrada
//============================================================================================================================================================
// Variables
//FILTER RATIO
double g_ibuf_96[], g_ibuf_100[], g_ibuf_104[], gda_112[], gda_116[], gda_120[], gda_124[], gda_128[], gda_132[], gd_136, gd_144, gd_152, gd_160, gd_168, gd_176, gd_184, gd_192, gd_200;
bool gi_80 = TRUE, gi_208 = FALSE, gi_212 = FALSE;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string diretorio = "History\\EURUSD.txt";
string diretorioBotCopy = dirBot+"Sinal.csv";
string diretorioFrankestain = hoje+"_retorno."+ExtensaoBots;
string terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH);

//+------------------------------------------------------------------+
//|                   CONFIGURAÇÕES_GERAIS                           |
//+------------------------------------------------------------------+
//============================================================================================================================================================
string ___________CONFIGURAÇÕES_GERAIS_____________= "===== CONFIGURAÇÕES_GERAIS ======================================================================"; //=================================================================================";
bool   AlertsSound = false;                     //Alerta Sonoro?
string  SoundFileUp          = "alert2.wav";    //Som do alerta CALL
string  SoundFileDown        = "alert2.wav";    //Som do alerta PUT
string  AlertEmailSubject    = "";              //Assunto do E-mail (vazio = desabilita).
bool    SendPushNotification = false;           //Notificações por PUSH?
//============================================================================================================================================================
//============================================================================================================================================================
//---- buffers
double up[];
double down[];
double CrossUp[];
double CrossDown[];
double AntilossUp[];
double AntilossDn[];
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double bufferMediaMovel[];
double bbUpper[], bbLower[];
double buffer1[];
double buffer2[];
double buffer3[];
double prices[];
double smBufDa[];
double smBufDb[];
double trend[];
//============================================================================================================================================================
int   Sig_UpCall0 = 0;
int   Sig_DnPut0 = 0;
int   Sig_DnPut1 = 0;
int   Sig_Up0 = 0;
int   Sig_Up1 = 0;
int   Sig_Dn0 = 0;
int   Sig_Dn1 = 0;
int   Sig_Up5 = 0;
int   Sig_Dn5 = 0;
datetime LastSignal;
//============================================================================================================================================================
//============================================================================================================================================================
int MAMode;
string strMAType;
double MA_Cur, MA_Prev;
datetime data;
int candlesup,candlesdn;

double VOpen[],VHigh[],VLow[],VClose[],Typical;
//============================================================================================================================================================
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
double M1stochK,M1stochD,M5stochK,M5stochD,M15stochK,M15stochD,M30stochK,M30stochD,H1stochK,H1stochD,H4stochK,H4stochD,D1stochK,D1stochD,StochK,StochD,StochKprev,StochDprev;
double MAM1,MAM5,MAM15,MAM30,MAH1,MAH4,MAD1,MAM1prev,MAM5prev,MAM15prev,MAM30prev,MAH1prev,MAH4prev,MAD1prev,MACurrent,MAPrevious;
double Spread,PSARCurrent,PSARPrev,MACDCurrent,MACDPrev,MACDSignal,MACDSignalPrev,MAXover1,MAXover2,VolumePercent,Vol,VolPrev,Bar1,Bar2,Bar3,Bar4,Bar5,Bar6,Bar7,Bar8,Bar9,Bar10;
double Bar1percent,Bar2percent,Bar3percent,Bar4percent,Bar5percent,BarsAverage1,BarsAverage2,BarsAverage3,BarsAverage4,BarsAverage5,BarsAllpercent;
int trendM1,trendM5,trendM15,trendM30,trendH1,trendH4,trendD1,PSAR,MACD,MAXoverSignal,VolValue,WPRValueUp,WPRValueDown,Bar1Col,Bar2Col,Bar3Col,Bar4Col,Bar5Col,BarReading,Signal;
//----------------------------------------------------------------------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#import "mt2trading_library.ex4"   // Please use only library version 13.52 or higher !!!
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes);
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes, string signalname);
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes, martintype martingaleType, int martingaleSteps, double martingaleCoef, broker myBroker, string signalName, string signalid);
int  traderesult(string signalid);
int getlbnum();
bool chartInit(int mid);
int updateGUI(bool initialized, int lbnum, string indicatorName, broker Broker, bool auto, double amount, int expiryMinutes);
int processEvent(const int id, const string& sparam, bool auto, int lbnum);
void showErrorText(int lbnum, broker Broker, string errorText);
void remove(const int reason, int lbnum, int mid);


#import "TopWinLib.ex4"
void TradeTopWin(string ativo, string direcao, int expiracao, int momento_entrada, string nomedosinal, datetime data_atual, int timeFrameGrafico);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cleanGUI();
#import
//============================================================================================================================================================
#import "Connector_Lib.ex4"
void put(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string vps);
void call(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string vps);
#import
//============================================================================================================================================================
#import "botpro_lib.ex4"
int botpro(string direction, int expiration, int martingale, string symbol, double value, string name, string bindig);
#import
//============================================================================================================================================================
#import "MX2Trading_library.ex4"
bool mx2trading(string par, string direcao, int expiracao, string SignalName, int Signaltipo, int TipoExpiracao, string TimeFrame, string mID, string Corretora);
#import
//============================================================================================================================================================
#import "Inter_Library.ex4"
int Magic(int time, double value, string active, string direction, double expiration_incandle, string signalname, int expiration_basic);
#import
//============================================================================================================================================================
#import "PriceProLib.ex4"
void TradePricePro(string ativo, string direcao, int expiracao, string nomedosinal, int martingales, int martingale_em, int data_atual, int corretora);
#import
//============================================================================================================================================================
#import "MambaLib.ex4"
void mambabot(string ativo, string sentidoseta, int timeframe, string NomedoSina);
#import
//============================================================================================================================================================
// Variables
int lbnum = 0;
datetime sendOnce;
int  Posicao = 0;
//============================================================================================================================================================
string asset;
string signalID;
string nc_section2 = "============ CÓDIGO ID!  ======================================================================================================="; // =========================================================================================
int mID = 0;      // ID (não altere)
//============================================================================================================================================================
//PAINEL
double win[],loss[],wg[],ht[],wg1,ht1,WinRate1,WinRateGale1,WinRateGale22,ht22,wg22,mb;
double Barcurrentopen,Barcurrentclose,Barcurrentopen1,Barcurrentclose1,Barcurrentopen2,Barcurrentclose2,m1,m2,lbk,wbk;
string WinRate;
string WinRateGale;
string WinRateGale2;
datetime tvb1;
int tb,g;
//============================================================================================================================================================
string s[];
datetime TimeBarEntradaUp;
datetime TimeBarEntradaDn;
datetime TimeBarUp;
datetime TimeBarDn;
datetime tempoEnvioTelegram;
double Resistencia[];
double Suporte[];
int x;
double m;
bool initgui = false;
datetime dfrom;
string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
string filePaths = terminalPath + "\\MQL4\\Files\\" + Symbol() + "_" + IntegerToString(_Period) + "SIGNAL.png";
string filePathsResult = terminalPath + "\\MQL4\\Files\\" + Symbol() + "_" + IntegerToString(_Period) + "RESULT.png";
  //+------------------------------------------------------------------+
// Double Moving Average Function
double MVA(int NumBars1, int CBar) {
  double sum = 0;  // Initialize sum to 0
  double floatingAxis;
  
  for (int k = CBar; k < NumBars1 + CBar; k++) {
    sum += ((High[k] + Low[k]) / 2.0);
  }
  
  floatingAxis = (sum / NumBars1);
  return (floatingAxis);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Support(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
         start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm));
      if(dt > start_time)
         dt -= 86400;
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count])
        {
         dt -= 86400;
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if(dt_index < 0)
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1;
     }
   double ret = Low[iLowest(NULL, 0, MODE_LOW, count, start_index)];
   if(draw)
      DrawLine("Support", ret, count, start_index);
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Resistance(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
         start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm));
      if(dt > start_time)
         dt -= 86400;
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count])
        {
         dt -= 86400;
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if(dt_index < 0)
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1;
     }
   double ret = High[iHighest(NULL, 0, MODE_HIGH, count, start_index)];
   if(draw)
      DrawLine("Resistance", ret, count, start_index);
   return(ret);
  }

// Average True Range Function
double ATR(int NumBars1, int CBar) {
  double sum = 0;  // Initialize sum to 0
  double volitilityUnit;
  
  for (int k = CBar; k < NumBars1 + CBar; k++) {
    sum += (High[k] - Low[k]);
  }
  
  volitilityUnit = (0.2 * (sum / NumBars1));
  if (volitilityUnit == 0 || volitilityUnit == 0.0) {
    volitilityUnit = 0.00000001;
  }
  return (volitilityUnit);
}
string chave;
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string objname, double price, int count, int start_index)
  {
   if((price < 0) && ObjectFind(objname) >= 0)
     {
      ObjectDelete(objname);
     }
   else
      if(ObjectFind(objname) >= 0 && ObjectType(objname) == OBJ_TREND)
        {
         ObjectSet(objname, OBJPROP_TIME1, Time[start_index]);
         ObjectSet(objname, OBJPROP_PRICE1, price);
         ObjectSet(objname, OBJPROP_TIME2, Time[start_index+count-1]);
         ObjectSet(objname, OBJPROP_PRICE2, price);
        }
      else
        {
         ObjectCreate(objname, OBJ_TREND, 0, Time[start_index], price, Time[start_index+count-1], price);
         ObjectSet(objname, OBJPROP_RAY, false);
         ObjectSet(objname, OBJPROP_COLOR, clrBlue);
         ObjectSet(objname, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet(objname, OBJPROP_WIDTH, 1);
        }
  }
//================================================================================================================================================
int OnInit()
  {
   if(use_main_window_image){
   string del_name="";
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      del_name=ObjectName(i);
      if(StringFind(del_name,label_name1)!=-1 || StringFind(del_name,separ_line_name)!=-1)
         ObjectDelete(del_name);
     }
   Comment("");
   if(comment_chart_resolution)
     {
      long main_chart_width_pix=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
      long main_chart_height_pix=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
      string com=StringConcatenate("Chart width:",string(main_chart_width_pix),"\nChart height:",string(main_chart_height_pix));
      Comment(com);
     }
   string name_create=NAME_OF_YOUR_BMP_FILE;
   for(int i=0; i<WindowsTotal(); i++)
     {
      if(!use_main_window_image && i==0)
         continue;
      if(!use_sub_window_image && i>0)
         break;
      if(i>0)
         name_create=Name_bmp_image_SW;
      //lab_name_plus_str=label_name1+string(i);
      ObjectCreate(0,"lab_name_plus_str",OBJ_BITMAP_LABEL,i,0,0);
      ObjectSetString(0,"lab_name_plus_str",OBJPROP_BMPFILE,"//Images//"+name_create+".bmp");
      ObjectSetInteger(0,"lab_name_plus_str",OBJPROP_XDISTANCE,X_shift);
      ObjectSetInteger(0,"lab_name_plus_str",OBJPROP_YDISTANCE,Y_shift);
      ObjectSetInteger(0,"lab_name_plus_str",OBJPROP_BACK,true);
      ObjectSetInteger(0,"lab_name_plus_str",OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,"lab_name_plus_str",OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,"lab_name_plus_str",OBJPROP_ZORDER,false);
     }
}
if(BGT){
// Create a label object for the background text
ObjectCreate(0, "BackgroundText", OBJ_LABEL, 0, 0, 0);

// Set the properties for the label
ObjectSetInteger(0, "BackgroundText", OBJPROP_CORNER, CORNER_LEFT_UPPER);  // Position in the upper left corner
ObjectSetInteger(0, "BackgroundText", OBJPROP_XDISTANCE, X_shiftb);             // Distance from the left edge
ObjectSetInteger(0, "BackgroundText", OBJPROP_YDISTANCE, Y_shiftb);             // Distance from the top edge
ObjectSetInteger(0, "BackgroundText", OBJPROP_FONTSIZE, 60);               // Font size
ObjectSetInteger(0, "BackgroundText", OBJPROP_COLOR, 0x424242);        // Font color
ObjectSetString(0, "BackgroundText", OBJPROP_TEXT, BT); // Text to display
ObjectSetString(0, "BackgroundText", OBJPROP_FONT, "IMPACT");              // Font type
ObjectSetInteger(0, "BackgroundText", OBJPROP_SELECTABLE, false);          // Non-selectable
ObjectSetInteger(0, "BackgroundText", OBJPROP_HIDDEN, true);               // Hidden in object list
ObjectSetInteger(0, "BackgroundText", OBJPROP_BACK, true);                 // Draw object as background
ObjectSetInteger(0, "BackgroundText", OBJPROP_ZORDER, 0);     

}
 if(COMPUTER_ID)
     {
      //--- indicator Seguranca Chave !!
      IndicatorSetString(INDICATOR_SHORTNAME,"GUNA COMBINER 1");
      string teste2 = StringFormat("%.32s", chave = VolumeSerialNumber());
      //============================================================================================================================================================
      string UniqueID = "E2FB-437C"; //MOHAMED TRADER
      string UniqueID1 = "7646-61A7";//VIJAY
      string UniqueID2 = "60FE-2136";//DHARM
      string UniqueID3 = "78DD-1DF9";//   BOURZ
      string UniqueID4 = "A437-C558";//DAZAI
      string UniqueID5 = "F4F3-DB7C";//JOHN MARTIN
      string UniqueID6 = "AC32-AF08";//SALIM
      string UniqueID7 = "2E99-7651";//MIKE
      string UniqueID8 = "7CEA-B642";//SILAS
      string UniqueID9 = "D416-1D15";//SUB
      string UniqueID10 ="CA06-754C";// ANAS
      string UniqueID11 = "";
      string UniqueID12 = "";
      string UniqueID13 = "";
      string UniqueID14 = "";
      string UniqueID15 = "";
      string UniqueID16 = "";
      string UniqueID17 = "";
      string UniqueID18 = "";
      string UniqueID19 = "";
      string UniqueID20 = "";
      string UniqueID21 = "";
      string UniqueID22 = "";
      string UniqueID23 = "";
      string UniqueID24 = "";
      string UniqueID25 = "";
      string UniqueID26 = "";
      string UniqueID27 = "";
      string UniqueID28 = "";
      string UniqueID29 = "";
      string UniqueID30 = "";
      string UniqueID31 = "";
      string UniqueID32 = "";
      string UniqueID33 = "";
      string UniqueID34 = "";
      string UniqueID35 = "";
      string UniqueID36 = "";
      string UniqueID37 = "";
      string UniqueID38 = "";
      string UniqueID39 = "";
      string UniqueID40 = "";
      string UniqueID41 = "";
      string UniqueID42 = "";
      string UniqueID43 = "";
      string UniqueID44 = "";
      string UniqueID45 = "";
      string UniqueID46 = "";
      string UniqueID47 = "";
      string UniqueID48 = "";
      string UniqueID49 = "";
      string UniqueID50 = "";
      string UniqueID51 = "";
      string UniqueID52 = "";
      string UniqueID53 = "";
      string UniqueID54 = "";
      string UniqueID55 = "";
      string UniqueID56 = "";
      string UniqueID57 = "";
      string UniqueID58 = "";
      string UniqueID59 = "";
      string UniqueID60 = "";
      string UniqueID61 = "";
      string UniqueID62 = "";
      string UniqueID63 = "";
      string UniqueID64 = "";
      string UniqueID65 = "";
      string UniqueID66 = "";
      string UniqueID67 = "";
      string UniqueID68 = "";
      string UniqueID69 = "";
      string UniqueID70 = "";
      string UniqueID71 = "";
      string UniqueID72 = "";
      string UniqueID73 = "";
      string UniqueID74 = "";
      string UniqueID75 = "";
      string UniqueID76 = "";
      string UniqueID77 = "";
      string UniqueID78 = "";
      string UniqueID79 = "";
      string UniqueID80 = "";
      string UniqueID81 = "";
      string UniqueID82 = "";
      string UniqueID83 = "";
      string UniqueID84 = "";
      string UniqueID85 = "";
      string UniqueID86 = "";
      string UniqueID87 = "";
      string UniqueID88 = "";
      string UniqueID89 = "";
      string UniqueID90 = "";
      string UniqueID91 = "";
      string UniqueID92 = "";
      string UniqueID93 = "";
      string UniqueID94 = "";
      string UniqueID95 = "";
      string UniqueID96 = "";
      string UniqueID97 = "";
      string UniqueID98 = "";
      string UniqueID99 = "";
      string UniqueID100 = "";
      string UniqueID101 = "";
      string UniqueID102 = "";
      string UniqueID103 = "";
      string UniqueID104 = "";
      string UniqueID105 = "";
      string UniqueID106 = "";
      string UniqueID107 = "";
      string UniqueID108 = "";
      string UniqueID109 = "";
      string UniqueID110 = "";
      string UniqueID111 = "";
      string UniqueID112 = "";
      string UniqueID113 = "";
      string UniqueID114 = "";
      string UniqueID115= "";
      string UniqueID116 = "";
      string UniqueID117 = "";
      string UniqueID118 = "";
      string UniqueID119 = "";
      string UniqueID120 = "";
      string UniqueID121 = "";
      string UniqueID122 = "";
      string UniqueID123 = "";
      string UniqueID124 = "";
      string UniqueID125 = "";
      string UniqueID126 = "";
      string UniqueID127 = "";
      string UniqueID128 = "";
      string UniqueID129 = "";
      string UniqueID130 = "";
      string UniqueID131 = "";
      string UniqueID132 = "";
      string UniqueID133 = "";
      string UniqueID134 = "";
      string UniqueID135 = "";
      string UniqueID136 = "";
      string UniqueID137 = "";
      //============================================================================================================================================================
      //Alert("WELCOME !!!");
      //============================================================================================================================================================
      if(UniqueID != teste2
         && UniqueID != teste2
         && UniqueID1 != teste2
         && UniqueID2 != teste2
         && UniqueID3 != teste2
         && UniqueID4 != teste2
         && UniqueID5 != teste2
         && UniqueID6 != teste2
         && UniqueID7 != teste2
         && UniqueID8 != teste2
         && UniqueID9 != teste2
         && UniqueID10 != teste2
         && UniqueID11 != teste2
         && UniqueID12 != teste2
         && UniqueID13 != teste2
         && UniqueID14 != teste2
         && UniqueID15 != teste2
         && UniqueID16 != teste2
         && UniqueID17 != teste2
         && UniqueID18 != teste2
         && UniqueID19 != teste2
         && UniqueID20 != teste2
         && UniqueID21 != teste2
         && UniqueID22 != teste2
         && UniqueID23 != teste2
         && UniqueID24 != teste2
         && UniqueID25 != teste2
         && UniqueID26 != teste2
         && UniqueID27 != teste2
         && UniqueID28 != teste2
         && UniqueID29 != teste2
         && UniqueID30 != teste2
         && UniqueID31 != teste2
         && UniqueID32 != teste2
         && UniqueID33 != teste2
         && UniqueID34 != teste2
         && UniqueID35 != teste2
         && UniqueID36 != teste2
         && UniqueID37 != teste2
         && UniqueID38 != teste2
         && UniqueID39 != teste2
         && UniqueID40 != teste2
         && UniqueID41 != teste2
         && UniqueID42 != teste2
         && UniqueID43 != teste2
         && UniqueID44 != teste2
         && UniqueID45 != teste2
         && UniqueID46 != teste2
         && UniqueID47 != teste2
         && UniqueID48 != teste2
         && UniqueID49 != teste2
         && UniqueID50 != teste2
         && UniqueID51 != teste2
         && UniqueID52 != teste2
         && UniqueID53 != teste2
         && UniqueID54 != teste2
         && UniqueID55 != teste2
         && UniqueID56 != teste2
         && UniqueID57 != teste2
         && UniqueID58 != teste2
         && UniqueID59 != teste2
         && UniqueID60 != teste2
         && UniqueID61 != teste2
         && UniqueID62 != teste2
         && UniqueID63 != teste2
         && UniqueID64 != teste2
         && UniqueID65 != teste2
         && UniqueID66 != teste2
         && UniqueID67 != teste2
         && UniqueID68 != teste2
         && UniqueID69 != teste2
         && UniqueID70 != teste2
         && UniqueID71 != teste2
         && UniqueID72 != teste2
         && UniqueID73 != teste2
         && UniqueID74 != teste2
         && UniqueID75 != teste2
         && UniqueID76 != teste2
         && UniqueID77 != teste2
         && UniqueID78 != teste2
         && UniqueID79 != teste2
         && UniqueID80 != teste2
         && UniqueID81 != teste2
         && UniqueID82 != teste2
         && UniqueID83 != teste2
         && UniqueID84 != teste2
         && UniqueID85 != teste2
         && UniqueID86 != teste2
         && UniqueID87 != teste2
         && UniqueID88 != teste2
         && UniqueID89 != teste2
         && UniqueID90 != teste2
         && UniqueID91 != teste2
         && UniqueID92 != teste2
         && UniqueID93 != teste2
         && UniqueID94 != teste2
         && UniqueID95 != teste2
         && UniqueID96 != teste2
         && UniqueID97 != teste2
         && UniqueID98 != teste2
         && UniqueID99 != teste2
         && UniqueID101 != teste2
         && UniqueID102 != teste2
         && UniqueID103 != teste2
         && UniqueID104 != teste2
         && UniqueID105 != teste2
         && UniqueID106 != teste2
         && UniqueID107 != teste2
         && UniqueID108 != teste2
         && UniqueID109 != teste2
         && UniqueID110 != teste2
         && UniqueID111 != teste2
         && UniqueID112 != teste2
         && UniqueID113 != teste2
         && UniqueID114 != teste2
         && UniqueID115 != teste2
         && UniqueID116 != teste2
         && UniqueID117 != teste2
         && UniqueID118 != teste2
         && UniqueID119 != teste2
         && UniqueID120 != teste2
         && UniqueID121 != teste2
         && UniqueID122 != teste2
         && UniqueID123 != teste2
         && UniqueID124 != teste2
         && UniqueID125 != teste2
         && UniqueID126 != teste2
         && UniqueID127 != teste2
         && UniqueID128 != teste2
         && UniqueID129 != teste2
         && UniqueID130 != teste2
         && UniqueID131 != teste2
         && UniqueID132 != teste2
         && UniqueID133 != teste2
         && UniqueID134 != teste2
         && UniqueID135 != teste2
         && UniqueID136 != teste2
         && UniqueID137 != teste2)
         //============================================================================================================================================================
        {
         Alert("YOUR COMPUTER ID :"+chave);
         Alert("SEND TELEGRAM:@its_guna24");
         ChartIndicatorDelete(0,0,"GUNA COMBINER 1");
         return(INIT_FAILED);
        }
     }
 for(int i = 0; i < 256; i++)
     {
    //  KingBinaryIndicatorProtector[i] = CharToStr(i);
     }

if(!acc_number_f())
      return(INIT_FAILED);
if (!acc_number_f()) {
        // If acc_number_f returns false, initialization fails
        return INIT_FAILED;
    }
    if(!acc_number_f())
      return(INIT_FAILED);
if (!acc_number_f()) {
        // If acc_number_f returns false, initialization fails
        return INIT_FAILED;
    }
    if(!acc_number_f())
      return(INIT_FAILED);
if (!acc_number_f()) {
        // If acc_number_f returns false, initialization fails
        return INIT_FAILED;
    }
    if(!acc_number_f())
      return(INIT_FAILED);
if (!acc_number_f()) {
        // If acc_number_f returns false, initialization fails
        return INIT_FAILED;
    }
    if(!acc_number_f())
      return(INIT_FAILED);
if (!acc_number_f()) {
        // If acc_number_f returns false, initialization fails
        return INIT_FAILED;
    }
    if(!acc_number_f())
      return(INIT_FAILED);
if (!acc_number_f()) {
        // If acc_number_f returns false, initialization fails
        return INIT_FAILED;
    }
 if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }

 if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }
   if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }
   if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }
   if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }
   if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }
   if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }
   if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }
   if(TimeCurrent() > StringToTime(ExpiryDate))
  {
   ChartIndicatorDelete(0, 0, "GUNA COMBINER V0.1");
   Alert("GUNA COMBINER expired Telegram : @its_guna24");
   return (INIT_FAILED);
  }



 

   if(mostrarID)
     {
      CreateTextLable("expiracao","ID p/ automatizar no @GUNAIQBot",9,"Segoe UI",clrWhite,3,10,50);
      CreateTextLable("expiracao1",string(AccountNumber()),9,"Segoe UI",clrGreenYellow,3,10,30);
     }

   if(!FileIsExist(dirBot+"ultimo_resultado.txt",0))
     {
      string fileHandleF = string(FileOpen(dirBot+"ultimo_resultado.txt",FILE_CSV|FILE_READ|FILE_WRITE));
      int dataF = int(TimeGMT())-10800;
      FileWrite(int(fileHandleF),dataF);
      FileClose(int(fileHandleF));
     }

   if(!FileIsExist(dirBot+hoje+"_results.txt",0))
     {
      string fileHandleF = string(FileOpen(dirBot+hoje+"_results.txt",FILE_CSV|FILE_READ|FILE_WRITE));
      string dataF = "";
      FileWrite(int(fileHandleF),dataF);
      FileClose(int(fileHandleF));
     }

//MUDA PRA OTC
   if(StringLen(Symbol())==10 && StringSubstr(Symbol(),7)=="OTC")
     {
      ModoOTC = true;
      ObjectCreate("modootc",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("modootc","Modo OTC Ativo", 13,"Segoe UI",clrDarkTurquoise);
      ObjectSet("modootc",OBJPROP_XDISTANCE,128*2);
      ObjectSet("modootc",OBJPROP_YDISTANCE,1*10);
      ObjectSet("modootc",OBJPROP_CORNER,4);
      Alert("Atenção: Para automatizar OTC somente com EABIBOT");
     }

  
//============================================================================================================================================================
//============================================================================================================================================================
// Relogio
   ObjectCreate("Time_Remaining",OBJ_LABEL,0,0,0);
//============================================================================================================================================================
   terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
//============================================================================================================================================================
//============================================================================================================================================================
   IndicatorShortName("GUNA COMBINER V0.1");
   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
   ChartSetInteger(0,CHART_FOREGROUND,FALSE);
   ChartSetInteger(0,CHART_SHIFT,TRUE);
   ChartSetInteger(0,CHART_AUTOSCROLL,TRUE);
   ChartSetInteger(0,CHART_SCALEFIX,FALSE);
   ChartSetInteger(0,CHART_SCALEFIX_11,FALSE);
   ChartSetInteger(0,CHART_SCALE_PT_PER_BAR,TRUE);
   ChartSetInteger(0,CHART_SHOW_OHLC,false);
   ChartSetInteger(0,CHART_SCALE,4);
   ChartSetInteger(0,CHART_SHOW_BID_LINE,TRUE);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,FALSE);
   ChartSetInteger(0,CHART_SHOW_LAST_LINE,FALSE);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,TRUE);
   ChartSetInteger(0,CHART_SHOW_GRID,FALSE);
   ChartSetInteger(0,CHART_SHOW_VOLUMES,FALSE);
   ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,FALSE);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrBlack);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrWhite);
   ChartSetInteger(0,CHART_COLOR_GRID,clrRed);
   ChartSetInteger(0,CHART_COLOR_VOLUME,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrGreen);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrWhite);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrGreen);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(0,CHART_COLOR_BID,clrIndigo);
   ChartSetInteger(0,CHART_COLOR_ASK,clrIndigo);
   ChartSetInteger(0,CHART_COLOR_LAST,clrIndigo);
   ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,clrIndigo);
   ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,FALSE);
   ChartSetInteger(0,CHART_DRAG_TRADE_LEVELS,FALSE);
   ChartSetInteger(0,CHART_SHOW_DATE_SCALE,true);
   ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,true);
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,FALSE);
//============================================================================================================================================================
   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
     {
      Alert("Permita importar dlls!");
      return(INIT_FAILED);
     }
//============================================================================================================================================================
   //SetIndexStyle(0, DRAW_ARROW, EMPTY,1,clrWhite);
   //SetIndexArrow(0, 233);
   SetIndexBuffer(0, up);
   SetIndexLabel(0, "Seta Call Compra");
//============================================================================================================================================================
  // SetIndexStyle(1, DRAW_ARROW, EMPTY,1,clrWhite);
   //SetIndexArrow(1, 234);
   SetIndexBuffer(1, down);
   SetIndexLabel(1, "Seta Put Venda");
//============================================================================================================================================================
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 2,clrLime);
   SetIndexArrow(2, 252);
   SetIndexBuffer(2, win);
   SetIndexLabel(2, "Marcador De Win");
//============================================================================================================================================================
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 2,clrRed);
   SetIndexArrow(3, 251);
   SetIndexBuffer(3, loss);
   SetIndexLabel(3, "Marcador De Loss");
//============================================================================================================================================================
   SetIndexStyle(4, DRAW_ARROW, EMPTY,1,clrLime);
   SetIndexArrow(4, 236);
   SetIndexBuffer(4, CrossUp);
   SetIndexLabel(4, "Pré alerta Call");
//============================================================================================================================================================
   SetIndexStyle(5, DRAW_ARROW, EMPTY,1,clrRed);
   SetIndexArrow(5, 238);
   SetIndexBuffer(5, CrossDown);
   SetIndexLabel(5, "Pré alerta Put");
//============================================================================================================================================================
   SetIndexStyle(6, DRAW_ARROW, EMPTY, 0, clrMagenta);
   SetIndexArrow(6, 233);
   SetIndexBuffer(6, AntilossUp);
   SetIndexLabel(6, "Antiloss Compra");
//============================================================================================================================================================
   SetIndexStyle(7, DRAW_ARROW, EMPTY, 0, clrMagenta);
   SetIndexArrow(7, 234);
   SetIndexBuffer(7, AntilossDn);
   SetIndexLabel(7, "Antiloss venda");
//============================================================================================================================================================
   SetIndexStyle(8, DRAW_ARROW, EMPTY,1,clrLime);
   SetIndexArrow(8, 252);
   SetIndexBuffer(8, wg);
   SetIndexLabel(8, "Marcador De Win Gale");
//============================================================================================================================================================
   SetIndexStyle(9, DRAW_ARROW, EMPTY, 0,clrRed);
   SetIndexArrow(9, 251);
   SetIndexBuffer(9, ht);
   SetIndexLabel(9, "Marcador De Hit Gale");
//============================================================================================================================================================
   SetIndexBuffer(10, Resistencia);
//SetIndexArrow(10, 158);
   SetIndexStyle(10, DRAW_LINE, STYLE_DASHDOTDOT, 1, mostrarSeR);
   SetIndexDrawBegin(10, x - 1);
   SetIndexLabel(10, "Resistencia");
//============================================================================================================================================================
   SetIndexBuffer(11, Suporte);
//SetIndexArrow(11, 158);
   SetIndexStyle(11, DRAW_LINE, STYLE_DASHDOTDOT, 1, mostrarSeR);
   SetIndexDrawBegin(11, x - 1);
   SetIndexLabel(11, "Suporte");
//============================================================================================================================================================
//BUFFERS AtivaDonchian
   SetIndexStyle(12,DRAW_LINE,EstiloDonChian,LarguraDonchian,clrNONE);
   SetIndexBuffer(12,ExtMapBuffer1);
   SetIndexStyle(13,DRAW_LINE,EstiloDonChian,LarguraDonchian,clrNONE);
   SetIndexBuffer(13,ExtMapBuffer2);

//LINHAS MEDIAS MOVEIS
   SetIndexStyle(14,DRAW_LINE, STYLE_SOLID, 6, clrGold);
   SetIndexBuffer(14,g_ibuf_96);

   SetIndexStyle(15,DRAW_LINE, STYLE_SOLID, 6, clrGreen);
   SetIndexBuffer(15,g_ibuf_100);

   SetIndexStyle(16,DRAW_LINE, STYLE_SOLID, 6, clrRed);
   SetIndexBuffer(16,g_ibuf_104);
   SetIndexStyle(17,DRAW_NONE);
   SetIndexBuffer(17,VHigh);
   SetIndexStyle(18,DRAW_NONE);
   SetIndexBuffer(18,VLow);
   SetIndexStyle(19,DRAW_NONE);
   SetIndexBuffer(19,VOpen);
   SetIndexStyle(20,DRAW_NONE);
   SetIndexBuffer(20,VClose);
     if( bandcolour){
   HalfLength=fmax(HalfLength,1);
   SetIndexBuffer(55,buffer1);
   SetIndexStyle(55, DRAW_LINE, EMPTY, 0,clrLime);
   SetIndexDrawBegin(55,HalfLength);
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
   SetIndexBuffer(56,smBufDa);
   SetIndexStyle(56, DRAW_LINE, EMPTY, 0,clrRed);
   SetIndexDrawBegin(56,HalfLength);
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
   SetIndexBuffer(57,smBufDb);
  SetIndexStyle(57, DRAW_LINE, EMPTY, 0,clrLime);
   SetIndexDrawBegin(57,HalfLength);
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
   SetIndexBuffer(58,buffer2);
   SetIndexStyle(58, DRAW_LINE, EMPTY, 0,clrRed);
   SetIndexDrawBegin(58,HalfLength);
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
   SetIndexBuffer(59,buffer3);
   SetIndexStyle(59, DRAW_LINE, EMPTY, 0,clrGreen);
   SetIndexDrawBegin(59,HalfLength);
   }
   else
   {
   HalfLength = fmax(HalfLength, 1);
SetIndexBuffer(55, buffer1);
SetIndexStyle(55, DRAW_NONE, EMPTY, 0, clrLime);
SetIndexDrawBegin(55, HalfLength);

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
SetIndexBuffer(56, smBufDa);
SetIndexStyle(56, DRAW_NONE, EMPTY, 0, clrRed);
SetIndexDrawBegin(56, HalfLength);

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
SetIndexBuffer(57, smBufDb);
SetIndexStyle(57, DRAW_NONE, EMPTY, 0, clrLime);
SetIndexDrawBegin(57, HalfLength);

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
SetIndexBuffer(58, buffer2);
SetIndexStyle(58, DRAW_NONE, EMPTY, 0, clrRed);
SetIndexDrawBegin(58, HalfLength);

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
SetIndexBuffer(59, buffer3);
SetIndexStyle(59, DRAW_NONE, EMPTY, 0, clrGreen);
SetIndexDrawBegin(59, HalfLength);
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
   SetIndexBuffer(60,prices);
   SetIndexStyle(60, DRAW_NONE, EMPTY, 1,clrWhiteSmoke);
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
   SetIndexBuffer(61,trend);
   SetIndexStyle(61, DRAW_NONE, EMPTY, 1,clrYellow);

//============================================================================================================================================================
   if(FiltroVelas)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }

   if(GUNAEstrategia)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }
//============================================================================================================================================================
   if(SeR)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }

//============================================================================================================================================================
   if(AtivaDonchian)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }

//============================================================================================================================================================
   if(Cci_Enabled)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }

//============================================================================================================================================================
   if(Adx_Enabled)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }
//============================================================================================================================================================
   if(Antiloss)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }
//============================================================================================================================================================
   if(COMBINER)
     {
      string carregando = "";
      CreateTextLable("carregando",carregando,14,"Segoe UI",clrYellow,2,10,25);
     }
//============================================================================================================================================================
   if(UsarRobo == 2)
     {
      string carregando = "Sending Signal  MX2...!";
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);
     }
//============================================================================================================================================================
   if(UsarRobo == 3)
     {
      string carregando = "Sending Signal BOTPRO...";
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);
     }
//============================================================================================================================================================
   if(UsarRobo == 4)
     {
      string carregando = "Sending Signal PRICEPRO...";
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);
     }
//============================================================================================================================================================
   if(UsarRobo == 7)
     {
      string carregando = "Sending Signal MT2...";
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);
     }
//============================================================================================================================================================
   if(UsarRobo == 8)
     {
      string carregando = "Sending Signal B2IQ...";
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);
     }
//============================================================================================================================================================
   if(UsarRobo == 5 || UsarRobo == 9)
     {
      string carregando = "Sending Signal TOPWIN...";
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);
     }
//============================================================================================================================================================
   if(UsarRobo == 1)
     {
      string carregando = "Sending Signal BOT...";
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);
     }

//============================================================================================================================================================
   CreateTextLable("programador","@its_guna24",9,"Arial Black",clrLavender,3,10,5);

   if(UsarRobo == 6)
     {

      if(!FileIsExist(diretorioFrankestain,0))
        {
         Print("Local do Arquivo: ", diretorioFrankestain);
         string fileHandleF = string(FileOpen(diretorioFrankestain,FILE_CSV|FILE_READ|FILE_WRITE));
         string dataF = "tempo,ativo,acao,expiracao";
         FileWrite(int(fileHandleF),dataF);
         FileClose(int(fileHandleF));

        }

      string carregando = ""+ExtensaoBots;
      CreateTextLable("carregando1",carregando,10,"Verdana",clrLavender,2,10,5);

     }
//==========
   if(Mãofixa)
     {
      string carregando = ""+string(FiltroMãofixa)+"";
      CreateTextLable("carregando2",carregando,10,"Arial",clrLime,1,10,27);
     }
//============================================================================================================================================================
   if(AplicaFiltroNoGale)
     {
      string carregando = ""+string(FiltroMartingale)+"";
      CreateTextLable("carregando3",carregando,10,"Arial",clrLime,1,10,44);
     }
//============================================================================================================================================================
   if(filtro_noticias)
     {
      string carregando = "";
      CreateTextLable("carregando3",carregando,10,"Arial",clrLime,1,10,44);
     }

//============================================================================================================================================================
   if(filtro_horario)
     {
      string carregando = "";
      CreateTextLable("carregando4",carregando,10,"Arial",clrLime,1,10,61);
     }
//============================================================================================================================================================
   if(AlertsMessage)
     {
      string carregando = "";
      CreateTextLable("carregando4",carregando,10,"Arial",clrLime,1,10,98);
     }

//============================================================================================================================================================
   if(Filtro_Tendencia)
     {
      string carregando = "";
      CreateTextLable("filtrotendencia",carregando,10,"Arial",clrLime,1,10,82);
     }

//============================================================================================================================================================
   if(FILT_RET)
     {
      string carregando = ""+string(GUNARatio)+"";
      CreateTextLable("filtroretracao",carregando,10,"Arial",clrLime,1,10,115);
     }

//============================================================================================================================================================
   if(Bloquea)
     {
      string carregando = ""+string(quantidade)+"";
      CreateTextLable("bloqueavelas",carregando,10,"Arial",clrLime,1,10,135);
     }

//============================================================================================================================================================
//SEGURANSA CHAVE---//
//============================================================================================================================================================
   EventSetTimer(1);
   chartInit(mID);  // Chart Initialization
   lbnum = getlbnum(); // Generating Special Connector ID

// Initialize the time flag
   sendOnce = TimeCurrent();
// Generate a unique signal id for MT2IQ signals management (based on timestamp, chart id and some random number)
   MathSrand(GetTickCount());
   if(MartingaleType == OnNextExpiry)
      signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand()) + " OnNextExpiry";   // For OnNextSignal martingale will be indicator-wide unique id generated
   else
      if(MartingaleType == Anti_OnNextExpiry)
         signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand()) + " AntiOnNextExpiry";   // For OnNextSignal martingale will be indicator-wide unique id generated
      else
         if(MartingaleType == OnNextSignal)
            signalID = IntegerToString(ChartID()) + IntegerToString(AccountNumber()) + IntegerToString(mID) + " OnNextSignal";   // For OnNextSignal martingale will be indicator-wide unique id generated
         else
            if(MartingaleType == Anti_OnNextSignal)
               signalID = IntegerToString(ChartID()) + IntegerToString(AccountNumber()) + IntegerToString(mID) + " AntiOnNextSignal";   // For OnNextSignal martingale will be indicator-wide unique id generated
            else
               if(MartingaleType == OnNextSignal_Global)
                  signalID = "MARTINGALE GLOBAL On Next Signal";   // For global martingale will be terminal-wide unique id generated
               else
                  if(MartingaleType == Anti_OnNextSignal_Global)
                     signalID = "MARTINGALE GLOBAL Anti On Next Signal";   // For global martingale will be terminal-wide unique id generated
//============================================================================================================================================================
// Symbol name should consists of 6 first letters
   if(StringLen(Symbol()) >= 6)
      asset = StringSubstr(Symbol(),0,6);
   else
      asset = Symbol();


//============================================================================================================================================================
   if(StringLen(Symbol()) > 6)
     {
      sendOnce = TimeGMT();
     }
   else
     {
      sendOnce = TimeCurrent();
     }
   funcFilterRatio();
      if(!GUNAEstrategia && !shadow  && !SNRG && !Elite_Enabled && !UsePSAR && !RSI_Enabled && ! BAND && !Filtro_Tendencia && !SeR && !ativar_donforex && !AtivaDonchian && !Cci_Enabled && !sniper_Enabled && !hacker_Enabled&& !BERSERK && !ninja_Enabled && !hulk_Enabled && !KILLER_Enabled && !BB_Enabled && !SO_Enabled && !strategy1_Enabled && !Reversal_Enabled && !KEN_Enabled && !candlestrtegy && !Pulback_Enabled && !EXTREME && !secret && !FLOW && !EnabledRVI && !EnabledMFI && !EnabledWPR &&!AtivarMACD && !Adx_Enabled && !AtivarCruzamento && !beast_Enabled && !priceaction && !strategy9_Enabled && !professor_Enabled && !HUNTER_Enabled && !Value_Enabled && !FILT_RET)
     {
      if(!COMBINER && !COMBINER2 && !COMBINER3 && !COMBINER4)
        {
         Alert("Turn on strategy or use external indicators");
         return(INIT_SUCCEEDED);
        }
      else
        {
         if(IndicatorName == "")
           {
            Alert("CHECK INDICATOR NAME");
            return(INIT_SUCCEEDED);
           }
        }

      if( IndicatorName2 == "")
        {
         Alert("CHECK INDICATOR NAME");
         return(INIT_SUCCEEDED);
        }

      if( IndicatorName3 == "")
        {
         Alert("CHECK INDICATOR NAME");
         return(INIT_SUCCEEDED);
        }

      if(IndicatorName4 == "")
        {
         Alert("CHECK INDICATOR NAME");
         return(INIT_SUCCEEDED);
        }
        }

   return(INIT_SUCCEEDED);
  }
//============================================================================================================================================================

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment(" ");
   ObjectsDeleteAll(0,"Text*");
   ObjectsDeleteAll(0,"Texto_*");
   ObjectsDeleteAll(0,"Linha_*");
   ObjectsDeleteAll(0, "FrameLabel*");
   ObjectsDeleteAll(0, "label*");
   ObjectDelete(0,"zexa");
   ObjectDelete(0,"Sniper");
   ObjectDelete(0,"Sniper1");
   ObjectDelete(0,"Sniper2");
   ObjectDelete(0,"Sniper3");
   ObjectDelete(0,"zexa");
   ObjectDelete(0,"Sniper");
   ObjectDelete(0,"Sniper1");
   ObjectDelete(0,"Sniper2");
   ObjectDelete(0,"Sniper3");
   ObjectDelete(0,"expiracao");
   ObjectDelete(0,"expiracao1");
   ObjectDelete(0,"modootc");
   ObjectDelete(0,"Sniper4");
   ObjectDelete(0,"Time_Remaining");
   ObjectDelete(0,"carregando");
   ObjectDelete(0,"carregando1");
   ObjectDelete(0,"carregando2");
   ObjectDelete(0,"carregando3");
   ObjectDelete(0,"carregando4");
   ObjectDelete(0,"filtrotendencia");
   ObjectDelete(0,"filtroretracao");
   ObjectDelete(0,"bloqueavelas");
   ObjectDelete(0,"carregando5");
   ObjectDelete(0,"programador");
   ObjectDelete(0,"cop");
   ObjectDelete(0,"pul");
   ObjectDelete(0,"pulo");
   ObjectDelete(0,"Win");
   ObjectDelete(0,"Loss");
   ObjectDelete(0,"WinRate");
   ObjectDelete(0,"WinGale");
   ObjectDelete(0,"WinRateGale");
   ObjectDelete(0,"Hit");
   ObjectDelete(0,"nomeFundo");
   ObjectDelete(0,"nomeFundo2");
   ObjectDelete(0,"BackgroundText");
   ObjectDelete(0,"lab_name_plus_str");
   FileDelete(UNIQUE_SIGNAL_FILE_NAME);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calctam()
  {
   if(Digits<=3)
     {return(0.001);}
   else
      if(Digits>=4)
        {return(0.00001);}
      else
        {
         return(0);
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tamanhodevela(int i)
  {
   double tamanho = calctam()*MinPips;


   if((High[i+0]-Low[i+0])<=tamanho)
     {return(true);}
   else
     {
      return(false);
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calctam1()
  {
   if(Digits<=3)
     {return(0.001);}
   else
      if(Digits>=4)
        {return(0.00001);}
      else
        {
         return(0);
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tamanhodevela1(int i)
  {
   double tamanho = calctam1()*maxPips;


   if((High[i+0]-Low[i+0])>=tamanho)
     {return(true);}
   else
     {
      return(false);
     }


  }
//============================================================================================================================================================
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
               )
  {
 
 
     
  //Se achar a dll, retorna um alerta de não liberado.. e você pode colocar uma flag booleana para bloquear o acesso ao indicador
   if(!ScanMaliciousFiles())

      if(TimeGMT()>D'07.02.2025')
        {
        Alert(KingBinaryIndicatorProtector[97] + KingBinaryIndicatorProtector[99] + KingBinaryIndicatorProtector[101] + KingBinaryIndicatorProtector[115] + KingBinaryIndicatorProtector[115] + KingBinaryIndicatorProtector[32] + KingBinaryIndicatorProtector[100] + KingBinaryIndicatorProtector[101] + KingBinaryIndicatorProtector[110] + KingBinaryIndicatorProtector[105] + KingBinaryIndicatorProtector[101] + KingBinaryIndicatorProtector[100]);
         ChartIndicatorDelete(0,0,"GUNA COMBINER V0.1");
         return(INIT_FAILED);
        }
//============================================================================================================================================================
   if(isNewBar())
     {
     }

   ResetLastError();
  double buffernew;
  int q,p,iCountedBars;
   if(MartingaleType == NoMartingale || MartingaleType == OnNextExpiry || MartingaleType == Anti_OnNextExpiry)
      signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand());   // For NoMartingale or OnNextExpiry martingale will be candle-wide unique id generated

//FIM DE FILTER RATIO
   ArrayResize(Resistencia,0);
   ArrayResize(Suporte,0);
   ArrayResize(CrossUp,0);
   ArrayResize(CrossDown,0);
   ChartRedraw(ChartID());
   if(liberar_acesso == true)
     {
      filterRatio();
               ////////////////////////////////////////////////////////////////////////////////////////////////////
          static bool first1=true;
          static int ratestotal1;
          iCountedBars=IndicatorCounted();
      if(iCountedBars < 0)
         return (-1);
      if(iCountedBars>0)
         iCountedBars--;
        ////////////////////////////////////////////////////////////////////////////////////////////////////// 
          int limit1=fmin(Bars-1,fmax(Bars-iCountedBars,HalfLength));
      limit1 = rates_total-prev_calculated>1 ? Velas : 0;
      limit1 = !first1 ? 0 : limit1;
      if(trend[limit1] == -1)
         CleanPoint(limit1,smBufDa,smBufDb);
      for(int i=limit1; i>=0; i--)
         prices[i] = getPrice(Price,Open,Close,High,Low,i);
      //-----------------------------------------------------------------------------------------------------------------------------------------------------------
      if(first1)
        {
         first1=false;
        }
        ///////////////////////////////////////////////////////////////////////////////////////////////////////
               if(BAND)
        {
         for(int i=limit1; i>=0; i--)
           {
            double sum1  = (HalfLength+1)*prices[i];
            double sumw1 = (HalfLength+1);
            for(q=1, p=HalfLength; q<=HalfLength; q++, p--)
              {
               sum1  += prices[i+q]*p;
               sumw1 += p;

               if(q<=i)
                 {
                  sum1  += prices[i-q]*p;
                  sumw1 += p;
                 }
              }
            buffer1[i] = sum1/sumw1;

            double range=0;
            switch(Type)
              {
               case st_atr :
                  range = iATR(NULL,0,period,i+DevLookBack);
                  break;
               case st_ste :
                  range = iStdError(prices[i], period,i+DevLookBack);
                  break;
               default :
                  range = iDeviation(prices[i],period,Type==st_sam,i+DevLookBack);
              }
            buffer2[i] = buffer1[i]+range*Multiplier;
            buffernew=buffer2[i+1];
            buffer3[i] = buffer1[i]-range*Multiplier;
            smBufDa[i] = EMPTY_VALUE;
            smBufDb[i] = EMPTY_VALUE;
            if(i<Bars-1)
              {
               trend[i] = trend[i+1];

               if(buffer1[i]>buffer1[i+1])
                  trend[i] = 1;

               if(buffer1[i]<buffer1[i+1])
                  trend[i] =-1;

               if(trend[i] == -1)
                  PlotPoint(i,smBufDa,smBufDb,buffer1);

               limit1=Velas;
               ratestotal1=rates_total;
              }
           }
        }
      for(int i=Velas; i>=0; i--)
        {
         dfrom = TimeCurrent() - 60 * 60 * 24*Velas;
         //Print(dfrom);
         if(Time[i] > dfrom)
           {

            //INICIA AS
            double up1, dn1, up2, dn2, up3, dn3, up4, dn4;
            bool up_GUNA, dn_GUNA, fora_banda_up, fora_banda_dn, up_adx,  dn_adx, alta = false, up_bb, dn_bb, up_so, dn_so, up_cci, dn_cci, up_GUNA_ok = false, dn_GUNA_ok = false, up_filter_ratio = false, dn_filter_ratio = false, ser_up, ser_dn;
            bool up_KEN, dn_KEN, up_strategy1, up_rsi, up_psar, dn_psar, dn_rsi, up_ao, dn_ao, up_elite, dn_elite, dn_strategy1, up_sg, dn_sg, up_price, dn_price, up_strategy9, dn_strategy9, up_HUNTER, dn_HUNTER, up_KILLER, dn_KILLER, up_berserk, dn_berserk, up_hulk, dn_hulk, up_professor, dn_professor, up_vc, dn_vc, up_beast, dn_beast, up_ninja, dn_ninja, up_sniper, dn_sniper, up_hacker, dn_hacker;
            
         //============================================================================================================================================================
         fasterEMAnow = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_CLOSE, i);
         fasterEMAprevious = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_OPEN, i);
         fasterEMAafter = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_CLOSE, i);
         //====================================================================================================================================
         slowerEMAnow = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_CLOSE, i);
         slowerEMAprevious = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_OPEN, i);
         slowerEMAafter = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_CLOSE, i);
         //==========================================================================================================
            double RVI = iRVI(Symbol(),Period(),PERIODORVI,Linha,i+1);//0 = Linha do RVI, 1 = Linha de sinal
            double MFI = iMFI(Symbol(),Period(),PERIODOMFI,i+mfiPrice);
            double WPR = iWPR(Symbol(),Period(),PERIODOWPR,i+wprPrice);
            double ema1 = iMA(NULL, 0, mediaMovel, 0, MODE_LWMA, PRICE_HIGH,i);
            double ema2 = iMA(NULL, 0, mediaMovel, 0, MODE_LWMA, PRICE_LOW,i);
            double CCI_3 = iCCI(NULL,_Period,PERIODOCCI_3,PRICE_TYPICAL,i);
            double CCI_2 = iCCI(NULL,_Period,PERIODOCCI_2,PRICE_TYPICAL,i+1);
            double RSI_2 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double RSI_6 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double MA_1 =iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,i);
            double RSI_3 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double RSI_4 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double RVI_3 = iRVI(Symbol(),Period(),PERIODRVI,0,i);//0 = Linha do RVI, 1 = Linha de sinal
            double WPR_2 = iWPR(Symbol(),Period(),PERIODOWPR2,i);
            double CCI_4 = iCCI(NULL,_Period,PERIODOCCI0_3,PRICE_TYPICAL,i);
            double RSI_5 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double RSI_7 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double RSI_8 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double CCI_6   = iCCI(NULL,PERIOD_CURRENT,CCI1_Period,Apply_to1,i);
            double CCI_7   = iCCI(NULL,PERIOD_CURRENT,CCI2_Period,Apply_too2,i);
            double RVI_4 = iRVI(Symbol(),Period(),PERIODORVI3,0,i);
            double CCI_8   = iCCI(NULL,PERIOD_CURRENT,CCI3_Period,Apply_to3,i);
            double RSI_9 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
            double CCI_9   = iCCI(NULL,PERIOD_CURRENT,CCI4_Period,Apply_to4,i);
            double RVI_5 = iRVI(Symbol(),Period(),PERIODORVI4,0,i);
            double WPR_3 = iWPR(Symbol(),Period(),PERIODOWPR3,i);
            double WPR_4 = iWPR(Symbol(),Period(),PERIODOWPR4,i);
            double CCI_10   = iCCI(NULL,PERIOD_CURRENT,CCI5_Period,Apply_to5,i);
            double CCI_11   = iCCI(NULL,PERIOD_CURRENT,CCI6_Period,Apply_to6,i);
            double PadraoVelas = (Open[i+1] + High[i+0] + Low[i+0] + Close[i+2]) / 4.0;
            
         //============================================================================================================================================================
         double ema3 = iMA(NULL, 0, 21, 1, MODE_EMA, PRICE_HIGH,i);
         double ema4 = iMA(NULL, 0,21, 1, MODE_EMA, PRICE_LOW,i);
         double vielas = (Open[i] + High[i] + Low[i] + Close[i]) / 4.0;
         double fractal1 = iFractals(NULL, 0, MODE_UPPER, i);
         if(fractal1 > 0.0 && vielas > ema3)
            Resistencia[i] = High[i];
         else
            Resistencia[i] = Resistencia[i+1];
         double fractal2 = iFractals(NULL, 0, MODE_LOWER, i);
         if(fractal2 > 0.0 && vielas < ema4)
            Suporte[i] = Low[i];
         else
            Suporte[i] = Suporte[i+1];
            hhb = iHighest(Symbol(),0,MODE_HIGH,dist,i+0);
            llb = iLowest(Symbol(),0,MODE_LOW,dist,i+0);
            
            
             bool bandup=false,banddown=false;
         if(BAND)
           {
            if(prices[i+bandshift]<buffer3[i+1+bandshift] && Close[i+bandshift]<Open[i+bandshift])
              {
               bandup=true;
              }
            else
              {
               bandup=false;
              }
            if(prices[i+bandshift]>buffer2[i+1+bandshift] && Close[i+bandshift]>Open[i+bandshift])
              {
               banddown=true;
              }
            else
              {
               banddown=false;
              }
           }
         else
           {
            bandup=true;
            banddown=true;
           }
         //+------------------------------------------------------------------+
         double Maxima = (iOpen(NULL,0,iHighest(NULL,0,MODE_OPEN,AtivaDonchian,i))+iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,AtivaDonchian,i)))/2;
         double Minima = (iOpen(NULL,0,iLowest(NULL,0,MODE_OPEN,AtivaDonchian,i))+iLow(NULL,0,iLowest(NULL,0,MODE_LOW,AtivaDonchian,i)))/2;
         Maxima=Maxima-(Maxima-Minima)*-2/100;
         Minima=Minima+(Minima-Maxima)*-2/100;
         //+------------------------------------------------------------------+
         double maximaEma = iMA(NULL, 0, 14, 1, MODE_EMA, PRICE_HIGH,i);
         double minimaEma = iMA(NULL, 0, 14, 1, MODE_EMA, PRICE_LOW,i);
         //+------------------------------------------------------------------+

            double velas = (Open[i] + High[i] + Low[i] + Close[i]) / 4;

            double fractal3 = iFractals(NULL, 0, MODE_UPPER, i);
            if(fractal3 > 0 && velas > ema1)
               Resistencia[i] = High[i];
            else
               Resistencia[i] = Resistencia[i+1];

            double fractal4 = iFractals(NULL, 0, MODE_LOWER, i);
            if(fractal4 > 0 && velas < ema2)
               Suporte[i] = Low[i];
            else
               Suporte[i] = Suporte[i+1];

            ser_up = (!SeR || (SeR && (Low[i] <= Suporte[i] && Open[i] >= Close[i]) && (High[i+1]>= Suporte[i+1])));  //Suporte e Resistencia // LOW
            ser_dn = (!SeR || (SeR && (High[i]>= Resistencia[i] && Open[i] <= Close[i]) && (Low[i+1] <= Resistencia[i+1])));  //Suporte e Resistencia // HIGHT


            //CANAIS DE AtivaDonchian
            if(AtivaDonchian)
              {

               double smin=0, smax=0, SsMax=0, SsMin=0;

               if(Extremes ==1)
                 {
                  SsMax = High[Highest(NULL,0,MODE_HIGH,Periods,i)];
                  SsMin = Low[Lowest(NULL,0,MODE_LOW,Periods,i)];
                 }
               else
                  if(Extremes == 3)
                    {
                     SsMax = (Open[Highest(NULL,0,MODE_OPEN,Periods,i)]+High[Highest(NULL,0,MODE_HIGH,Periods,i)])/2;
                     SsMin = (Open[Lowest(NULL,0,MODE_OPEN,Periods,i)]+Low[Lowest(NULL,0,MODE_LOW,Periods,i)])/2;
                    }
                  else
                    {
                     SsMax = Open[Highest(NULL,0,MODE_OPEN,Periods,i)];
                     SsMin = Open[Lowest(NULL,0,MODE_OPEN,Periods,i)];
                    }

               smin = SsMin+(SsMax-SsMin)*Margins/100;
               smax = SsMax-(SsMax-SsMin)*Margins/100;
               ExtMapBuffer1[i-Advance]=smin;
               ExtMapBuffer2[i-Advance]=smax;

               if(Close[i] < smin && !alta)
                 {
                  alta = true;
                  fora_banda_up = true;
                 }
               else
                 {
                  fora_banda_up = false;
                 }

               if(Close[i] > smax && alta)
                 {
                  alta = false;
                  fora_banda_dn = true;
                 }
               else
                 {
                  fora_banda_dn = false;
                 }
              }
            else
              {
               fora_banda_up = true;
               fora_banda_dn = true;
              }
          // PRICE ACTION   
         //============================================================================================================================================================
         if(priceaction)
           {
            //============================================================================================================================================================
            if((High[i+0] >= Suporte[i+0]) &&(Low[i+0] <=Suporte[i+0]))
               //============================================================================================================================================================
               up_price = true;
            else
               up_price = false;
            //============================================================================================================================================================
            if((Low[i+0] <=Resistencia[i+0]) &&(High[i+0] >= Resistencia[i+0]))
               //============================================================================================================================================================
               dn_price = true;
            else
               dn_price = false;
            //============================================================================================================================================================
           }
         else
           {
            up_price = true;
            dn_price = true;
           }
         //============================================================================================================================================================
            if(SNRG)
        {


         up_ao =


            Low[i+2] > Support(TF * 60, false, 00, 00, false, i+2)
            && Low[i+1] > Support(TF * 60, false, 00, 00, false, i+1)

            && Low[i]   <= Support(TF * 60, false, 00, 00, false, i);





         dn_ao =  High[i+2] < Resistance(TF * 60, false, 00, 00, false, i+2)
                  && High[i+1] < Resistance(TF * 60, false, 00, 00, false, i+1)

                  && High[i]  >= Resistance(TF * 60, false, 00, 00, false, i);


        }
      else
        {


         up_ao = true;
         dn_ao = true;


        }
                    
           //====================================================================================================================================               

         if(RSI_Enabled) {
            up_rsi = iRSI(NULL, RSITimeFrame, RSI_Period, RSI_Price, i) < RSI_MIN;
            dn_rsi = iRSI(NULL, RSITimeFrame, RSI_Period, RSI_Price, i) > RSI_MAX;
         } else {
            up_rsi = true;
            dn_rsi = true;
         }   
            //CCI  
            //==================================================================================================================================== 
            if(strategy1_Enabled) {
            up_strategy1 = Close[i+0]<iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_LOWER,i+0)
                       && Open[i+0]>iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_LOWER,i+0)
                       && Open[i+1]>iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_LOWER,i+1)
                       && Close[i+1]>iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_LOWER,i+1)
                       && CCI_3<MINCCI_3;

            dn_strategy1 = Close[i+0]>iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_UPPER,i+0)
                       && Open[i+0]<iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_UPPER,i+0)
                       && Open[i+1]<iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_UPPER,i+1)
                       && Close[i+1]<iBands(NULL,PERIOD_CURRENT,BB_Period1,BB_Dev1,BB_Shift1,0,MODE_UPPER,i+1)
                       && CCI_3>MAXCCI_3;
         } else {
            up_strategy1 = true;
            dn_strategy1 = true;
         }
  
         //KEN
         //====================================================================================================================================         
         if(KEN_Enabled){
            up_KEN = (CCI_2>MINCCI_2 && RSI_2<=MinRSI );
            dn_KEN = (CCI_2<MAXCCI_2 && RSI_2>=MaxRSI);
            } else 
            { 
            up_KEN = true;
            dn_KEN = true;
            }
            
        //==========================================================================================================================
         if(sniper_Enabled)
           {
            up_sniper  = CCI_10<CCI5_Oversold_Level && WPR_4<=MINWPR4;
            dn_sniper  = CCI_10>CCI5_Overbought_Level && WPR_4>=MINWPR4;
           }
         else
           {
            up_sniper = true;
            dn_sniper = true;
           }

        //==========================================================================================================================

         if(ninja_Enabled)
           {
            up_ninja = iRSI(NULL, RSITimeFrame1, RSI1_Period, RSI1_Price, i) < RSI1_MIN
                      && iRSI(NULL, RSITimeFrame2, RSI2_Period, RSI2_Price, i) < RSI2_MIN
                      && iRSI(NULL, RSITimeFrame3, RSI3_Period, RSI3_Price, i) < RSI3_MIN
                      ;
            dn_ninja = iRSI(NULL, RSITimeFrame1, RSI1_Period, RSI1_Price, i) > RSI1_MAX
                      && iRSI(NULL, RSITimeFrame2, RSI2_Period, RSI2_Price, i) > RSI2_MAX
                      && iRSI(NULL, RSITimeFrame3, RSI3_Period, RSI3_Price, i) > RSI3_MAX

                      ;
           }
         else
           {
            up_ninja = true;
            dn_ninja = true;
           }
        //==========================================================================================================================
         if(professor_Enabled)
           {
            up_professor = CCI_8<CCI3_Oversold_Level && RSI_9<=MinRSI_9 ;
            dn_professor =   CCI_8>CCI3_Overbought_Level && RSI_9>=MaxRSI_9 ;
           }
         else
           {
            up_professor = true;
            dn_professor = true;
           }
            
         //====================================================================================================================================
         //double trd1 = iCustom(Symbol(),Period(),"val",3,i);
         double MA = iMA(NULL,PERIOD_CURRENT,MA_Period,MA_Shift,MA_Method,MA_Applied_Price,i+FilterShift);
         double RVI_2 = iRVI(Symbol(),Period(),PERIODORVI,0,i);//0 = Linha do RVI, 1 = Linha de sinal
         MFI = iMFI(Symbol(),Period(),PERIODOMFI,i);
         WPR = iWPR(Symbol(),Period(),PERIODOWPR,i);
         fasterEMAnow = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_TYPICAL, i);
         fasterEMAprevious = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_TYPICAL, i+1);
         fasterEMAafter = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_TYPICAL, i-1);
         //====================================================================================================================================
         slowerEMAnow = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_TYPICAL, i);
         slowerEMAprevious = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_TYPICAL, i+1);
         slowerEMAafter = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_TYPICAL, i-1);
        //==========================================================================================================================
         if(hulk_Enabled)
           {
            up_hulk = CCI_7<CCI2_Oversold_Level && RVI_4<=MINRVI3 ;
            dn_hulk =   CCI_7>CCI2_Overbought_Level && RVI_4>=MAXRVI3 ;
           }
         else
           {
            up_hulk = true;
            dn_hulk = true;
           }
            
       //====================================================================================================================================

         if(HUNTER_Enabled)
           {
            up_HUNTER = Close[i+0]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+0)
                      && Open[i+0]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+0)
                      && Open[i+1]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+1)
                      && Close[i+1]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+1)
                      && (CCI_4<MAXCCI_03 && RSI_5<=MaxRSI_2);

            dn_HUNTER =  Close[i+0]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+0)
                       && Open[i+0]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+0)
                       && Open[i+1]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+1)
                       && Close[i+1]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+1)
                       && (CCI_4>MINCCI_03 && RSI_5>=MinRSI_2);

           }
         else
           {
            up_HUNTER = true;
            dn_HUNTER = true;
           }
           
           
        //==========================================================================================================================
         if(KILLER_Enabled)
           {
            up_KILLER = RSI_7<=MinRSI_7 ;
            dn_KILLER =  RSI_7>=MaxRSI_7 ;
           }
         else
           {
            up_KILLER = true;
            dn_KILLER = true;
           }
            //Reversal
           //====================================================================================================================================      
          if(Reversal_Enabled){
            up_sg =  RSI_2<=MinRSI_2 && RSI_3<=MinRSI_3 && RSI_4<=MinRSI_4 ;
            dn_sg =  RSI_2>=MaxRSI_2 && RSI_3>=MinRSI_3 && RSI_4>=MinRSI_4  ;
            } else 
            { 
            up_sg = true;
            dn_sg = true;
            }  
            
          //==========================================================================================================================
         if(BERSERK)
           {
            up_berserk = RSI_8<=MinRSI_8 && CCI_6<CCI1_Oversold_Level ;
            dn_berserk =  RSI_8>=MaxRSI_8 && CCI_6>CCI1_Overbought_Level ;
           }
         else
           {
            up_berserk = true;
            dn_berserk = true;
           } 
            
             //CCI
            //====================================================================================================================================
            if(Cci_Enabled)
              {
               double CCI   = iCCI(NULL,PERIOD_CURRENT,CCI_Period,Apply_to,i);
               up_cci  = CCI<CCI_Oversold_Level;
               dn_cci  = CCI>CCI_Overbought_Level;
              }
            else
              {
               up_cci = true;
               dn_cci = true;
              }
//====================================================================================================================================
if (UsePSAR) 
   {
      up_psar = (Close[i] > iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i) &&
                 Open[i] > iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i) &&
                 Close[i + 1] > iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i + 1) &&
                 Open[i + 1] > iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i + 1));

      dn_psar = (Close[i] < iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i) &&
                 Open[i] < iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i) &&
                 Close[i + 1] < iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i + 1) &&
                 Open[i + 1] < iSAR(NULL, PERIOD_CURRENT, PSAR_Step, PSAR_Maximum, i + 1));
   } 
   else 
   {
      up_psar = true;
      dn_psar = true;
   }
//====================================================================================================================================
         if(Elite_Enabled)
         {
         up_elite  =  (!EnabledRVI || EnabledRVI<=MINRVI)  && (!EnabledMFI || MFI<=MINMFI)
         && (!EnabledWPR || EnabledWPR<=MINWPR) && (!FiltroVelas==1 || Open[i]>Close[i])
          ;

         dn_elite   = (!EnabledRVI || RVI>=MAXRVI) && (!EnabledMFI || EnabledMFI>=MAXMFI) 
         && (!EnabledWPR || EnabledWPR>=MAXWPR) && (!FiltroVelas==1 || Open[i]<Close[i])  
           ;

         }
         else
         {
         up_elite = true;
         dn_elite = true;
         } 

           //==========================================================================================================================

         if(hacker_Enabled)
           {
            up_hacker = Close[i+0]<iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_LOWER,i+0)
                        && Open[i+0]>iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_LOWER,i+0)
                        && Open[i+1]>iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_LOWER,i+1)
                        && Close[i+1]>iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_LOWER,i+1)
                        && CCI_11<CCI6_Oversold_Level
                        ;
            dn_hacker = Close[i+0]>iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_UPPER,i+0)
                        && Open[i+0]<iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_UPPER,i+0)
                        && Open[i+1]<iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_UPPER,i+1)
                        && Close[i+1]<iBands(NULL,PERIOD_CURRENT,BB2_Period,BB2_Dev,BB2_Shift,0,MODE_UPPER,i+1)
                        && CCI_11>CCI6_Overbought_Level
                        ;
           }
         else
           {
            up_hacker = true;
            dn_hacker = true;
           }
         //==========================================================================================================================

         if(strategy9_Enabled)
           {
            up_strategy9  = RVI_3<=MINIRVI && WPR_2<=MINWPR2 ;
            dn_strategy9  = RVI_3>=MAXIRVI && WPR_2>=MAXWPR2 ;
           }
         else
           {
            up_strategy9 = true;
            dn_strategy9 = true;
           }
           
           
        //==========================================================================================================================
         if(beast_Enabled)
           {
            up_beast = CCI_9<CCI4_Oversold_Level && RVI_5<=MINRVI4 && WPR_3<=MINWPR3 ;
            dn_beast = CCI_9>CCI4_Overbought_Level && RVI_5>=MAXRVI4 && WPR_3>=MAXWPR3 ;
           }
         else
           {
            up_beast = true;
            dn_beast = true;
           }

        //====================================================================================================================================
         if(Value_Enabled)
           {
            // Chamada da Função do Value Chart
            //+------------------------------------------------------------------+

            VOpen[i]    = (Open[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
            VHigh[i]    = (High[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
            VLow[i]     = (Low[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
            VClose[i]   = (Close[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));

            //+------------------------------------------------------------------+

            // Verificação do Sinal do Value Chart
            up_vc = VClose[i] <= VC_MIN;
            dn_vc = VClose[i] >= VC_MAX;
           }
         else
           {
            up_vc = true;
            dn_vc = true;
           }
           //============================================================================================================================
           
          //BOLINGARBAND
         //==========================================================================================================================

         if(BB_Enabled) {
            up_bb = Close[i] < iBands(NULL, BBTimeFrame, BB_Period, BB_Deviations, BB_Shift, BB_Price, MODE_LOWER, i);
            dn_bb = Close[i] > iBands(NULL, BBTimeFrame, BB_Period, BB_Deviations, BB_Shift, BB_Price, MODE_UPPER, i);
         } else {
            up_bb = true;
            dn_bb = true;
         }                    
         
           //STOCHASTIC
          //====================================================================================================================================      
         if(SO_Enabled) {
            up_so = iStochastic(NULL, STCTimeFrame, SO_KPeriod, SO_DPeriod, SO_Slowing, SO_Mode, SO_Price, MODE_SIGNAL, i) < SO_MIN;
            dn_so = iStochastic(NULL, STCTimeFrame, SO_KPeriod, SO_DPeriod, SO_Slowing, SO_Mode, SO_Price, MODE_SIGNAL, i) > SO_MAX;
         } else {
            up_so = true;
            dn_so = true;
         } 
         
            //ADX
            //==========================================================================================================================

           if(Adx_Enabled)
              {
               double ADX = iADX(NULL,0,period_adx,price_adx,MODE_MAIN, i);
               up_adx  = (ADX<=level_adx);
               dn_adx  = (ADX>=level_adx);
              }
            else
              {
               up_adx = true;
               dn_adx = true;
              }
            if(GUNAEstrategia)
              {
               double RSI_1 = iRSI(Symbol(),Period(),PeriodoRSI,PRICE_OPEN,i);
               //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
               if(Low[i+0] <= Suporte[i+0] && Open[i] > Close[i]
                  && ser_up //Suporte e Resistencia
                  && (RSI_1<=MinRSI))
                  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  up_GUNA = true;
               else
                  up_GUNA = false;
               //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
               if(High[i+0]>= Resistencia[i+0] && Open[i] < Close[i]
                  && ser_dn  //Suporte e Resistencia
                  && (RSI_1>=MaxRSI))
                  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  dn_GUNA = true;
               else
                  dn_GUNA = false;
               ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
               //+------------------------------------------------------------------+
               //|                                                                  |
               //+------------------------------------------------------------------+
              }
            else
              {
               up_GUNA = true;
               dn_GUNA = true;
              }

            if(Filtro_Tendencia)
              {
               if(g_ibuf_100[i+1] !=EMPTY_VALUE)   //RED
                 {
                  up_filter_ratio = true;
                 }
               else
                  if(g_ibuf_104[i+1] !=EMPTY_VALUE)   //GREEN
                    {
                     dn_filter_ratio = true;
                    }
              }
            else
              {
               up_filter_ratio = true;
               dn_filter_ratio = true;
              }

            //+------------------------------------------------------------------+
            //|  FILTRO DE RETRAÇÃO                                              |
            //+------------------------------------------------------------------+

            if(FILT_RET)
              {
               if(Close[i] > Open[i])
                  dn_GUNA_ok = (Close[i] - Open[i])/((High[i] - Open[i])+0.0000001) > ((double)GUNARatio)/100;

               else
                  up_GUNA_ok = (Open[i] - Close[i])/((Open[i] - Low[i])+0.0000001) > ((double)GUNARatio)/100;
              }
            else
              {
               up_GUNA_ok = true;
               dn_GUNA_ok = true;
              }

         //-----------------------------------------------------------------------------------------------------------------------------------------------------------
         // MACD ---------------------------------------
         //-----------------------------------------------------------------------------------------------------------------------------------------------------------
         MACDCurrent = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_CLOSE,MODE_MAIN,i);
         MACDPrev = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_OPEN,MODE_MAIN,i);
         MACDSignal = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_CLOSE,MODE_SIGNAL,i);
         MACDSignalPrev = iMACD(NULL,0,MACD_Period1,MACD_Period2,MACD_Period3,PRICE_OPEN,MODE_SIGNAL,i);

         if(MACDCurrent>MACDPrev && ((MACDCurrent && MACDPrev)>MACDSignal || (MACDCurrent && MACDPrev)<MACDSignal))
           {
            MACD=3;
           }
         if(MACDCurrent<MACDSignal && MACDPrev>MACDSignalPrev)
           {
            MACD=2;
           }
         if(MACDCurrent<MACDPrev && ((MACDCurrent && MACDPrev)>MACDSignal || (MACDCurrent && MACDPrev)<MACDSignal))
           {
            MACD=1;
           }
         if(MACDCurrent>MACDSignal && MACDPrev<MACDSignalPrev)
           {
            MACD=0;
           }
         if(MACDCurrent>0 && MACDPrev<0)
           {
            MACD=4;
           }
         if(MACDCurrent<0 && MACDPrev>0)
           {
            MACD=5;
           }
         //+------------------------------------------------------------------+

            //============================================================================================================================================================
            //============================================================================================================================================================
            // primeiro indicador
            if(COMBINER)
              {
               up1 = iCustom(NULL, 0, IndicatorName, IndiBufferCall, i+SignalType);
               dn1 = iCustom(NULL, 0, IndicatorName, IndiBufferPut, i+SignalType);
               up1 = sinal_buffer(up1);
               dn1 = sinal_buffer(dn1);
              }
            else
              {
               up1 = true;
               dn1 = true;
              }
            //============================================================================================================================================================
            //============================================================================================================================================================
            // segundo indicador
            if(COMBINER2)
              {
               up2 = iCustom(NULL, 0, IndicatorName2, IndiBufferCall2, i+SignalType2);
               dn2 = iCustom(NULL, 0, IndicatorName2, IndiBufferPut2, i+SignalType2);
               up2 = sinal_buffer(up2);
               dn2 = sinal_buffer(dn2);
              }
            else
              {
               up2 = true;
               dn2 = true;
              }
            //TERCEIRO INDICADOR
            if(COMBINER3)
              {
               up3 = iCustom(NULL, 0, IndicatorName3, IndiBufferCall3, i+SignalType3);
               dn3 = iCustom(NULL, 0, IndicatorName3, IndiBufferPut3, i+SignalType3);
               up3 = sinal_buffer(up3);
               dn3 = sinal_buffer(dn3);
              }
            else
              {
               up3 = true;
               dn3 = true;
              }

            //QUARTO INDICADOR
            if(COMBINER4)
              {
               up4 = iCustom(NULL, 0, IndicatorName4, IndiBufferCall4, i+SignalType4);
               dn4 = iCustom(NULL, 0, IndicatorName4, IndiBufferPut4, i+SignalType4);
               up4 = sinal_buffer(up4);
               dn4 = sinal_buffer(dn4);
              }
            else
              {
               up4 = true;
               dn4 = true;
              }

            //ESTRATEGIA GUNA
            //============================================================================================================================================================
            if(Bloquea)
              {
               candlesup=0;
               candlesdn=0;
               int j;
               for(j = i+quantidade+1 ; j>=i; j--)
                 {
                  if(close[j+1]>=open[j+1]) // && close[j+2] > open[j+2])
                     candlesup++;
                  else
                     candlesup=0;
                  if(close[j+1]<=open[j+1]) // && close[j+2] < open[j+2])
                     candlesdn++;
                  else
                     candlesdn = 0;
                 }
              }

            //============================================================================================================================================================
            //============================================================================================================================================================
            if( //CALL  ----  ACIMA
               //============================================================================================================================================================
               up[i] == EMPTY_VALUE
               && Close[i]<Open[i]
               && CrossUp[i+1]==EMPTY_VALUE
               && CrossDown[i+1] ==EMPTY_VALUE
               && bandup
               && up1  // Combiner 
               && up2  // Combiner2
               && up3  // Combiner3
               && up4  // Combiner2
               && up_GUNA //GUNA ESTRATEGIA
               && fora_banda_up //AtivaDonchian
               && up_price  //PRICE ACTION
               && up_cci //CCI
               && up_adx //ADX
               && up_bb //BOLINGARBAND
               && up_strategy1 //strategy1
               && up_KEN //KEN
               && up_sg  //Reversal
               && up_strategy9 //SNIPER
               && up_HUNTER //HUNTER
               && up_KILLER //  KILLER
               && up_berserk // BERSERK 
               && up_hulk //HULK
               && up_professor  //PROFESSOR
               && up_vc // VALUE CHART
               && up_beast //BEAST
               && up_ninja //REAPER
               && up_sniper //CRUSHER
               && up_hacker //DRAGON
               && up_rsi //RSI
               && up_psar//PSAR
               && up_ao //
               && (!shadow || (shadow && PadraoVelas < minimaEma && close[i]<open[i]))
               &&(!candlestrtegy || (Open [i+1] > Close [i+1])) &&(!candlestrtegy || (Open [i] < Close [i]))
               &&(!candlestrtegy || (Close[i+1] < Open [i])) &&(!candlestrtegy || (Open [i+1] > Close [i]))
               &&(!Pulback_Enabled || (RSI_6<=MinRSI_6 &&Padrao("call", i) && Close[i+FilterShift]>MA_1))
               &&(!EXTREME || (i==llb))
               &&(!secret || TimeMinute(Time[i])==59)  &&(!secret || Padrao("call", i))  && (!AtivaDonchian || (AtivaDonchian && (iLow(NULL,0,i)<Minima && close[i]<open[i])))
               &&(!EnabledRVI || RVI<=MINRVI) &&(!EnabledMFI || MFI<=MINMFI) &&(!EnabledWPR || WPR<=MAXWPR) &&(!FLOW || (i==hhb))
               &&(!AtivarMACD || MACDCurrent<MACDPrev) &&(!AtivarMACD || MACDCurrent) &&(!AtivarMACD || MACDPrev>MACDSignal) &&(!AtivarMACD || MACDCurrent)
               &&(!AtivarCruzamento || fasterEMAnow > slowerEMAnow) &&(!AtivarCruzamento || fasterEMAprevious < slowerEMAprevious) &&(!AtivarCruzamento || fasterEMAafter > slowerEMAafter)
               && up_so //STOCHASTIC
               && up_GUNA_ok //FILTRO DE RETRAÇÃO
               && (!ativar_donforex || DonForex(i, true)) //DOMFOREX
               && down[i] == EMPTY_VALUE
               && up_filter_ratio //FILTER RATIO
               && ((AtivarTamanhoVela && tamanhodevela(i)) || !AtivarTamanhoVela)
               && ((AtivarTamanhoVela1 && tamanhodevela1(i)) || !AtivarTamanhoVela1)
               && (!Bloquea || candlesdn < quantidade)
               //============================================================================================================================================================
               && ser_up //SUPORTE E RESISTENCIA UP
               //============================================================================================================================================================
               && (!FiltroVelas || (FiltroVelas && Open[i] < Close[i+1]))  //Filtro Velas
            )
              {
               if(Time[i] > LastSignal + (Period()*Intervalo)*60)
                 {
                 if(DirectionSignal){
                 if(enviar_telegram)
                  LastSignal = Time[0];

                  CrossUp[i] = iLow(_Symbol,PERIOD_CURRENT,i);

                  if(Entrada==ATIVAR_PRE_ALERTA && i ==0)
                    {
                     Sig_Up0=1;
                     if(noDellArrow && enviar_telegram)
                       {
                        Print("Caiu enviar telegram, CALL");
                        enviaTelegram("CALL");
                       }
                    }
                  }
                  else{
                  if(enviar_telegram)
                  LastSignal = Time[0];

                  CrossDown[i] = iHigh(_Symbol,PERIOD_CURRENT,i);

                  if(Entrada==ATIVAR_PRE_ALERTA && i ==0)
                    {
                     Sig_Dn0=1;
                     if(noDellArrow && enviar_telegram)
                       {
                        Print("Caiu enviar telegram, PUT");
                        enviaTelegram("PUT");
                       }
                    }
                  }
                 }
              }
            else
              {
              if(DirectionSignal){
               Sig_Up0=0;
               if(i == 0 && !enviar_telegram)
                 {
                  CrossUp[i] = EMPTY_VALUE;
                 }
                 }
                 else{
                 Sig_Dn0=0;
               if( i == 0 && !enviar_telegram)
                 {
                  CrossDown[i] = EMPTY_VALUE;

                 }
                 }
              }
            //============================================================================================================================================================
            //PUT ------  ABAIXO
            if(
               //============================================================================================================================================================
               up[i] == EMPTY_VALUE
               && Close[i]>Open[i]
               && banddown
               && CrossUp[i+1]==EMPTY_VALUE
               && CrossDown[i+1] ==EMPTY_VALUE
               && dn1   // Combiner1
               && dn2   // Combiner2
               && dn3   // Combiner3
               && dn4   // Combiner2
               && dn_cci // CCI
               && dn_adx //ADX
               && dn_bb //BOLINGARBAND
               && dn_strategy1 //strategy1
               && dn_KEN //KEN
               && dn_sg  //Reversal
               && dn_strategy9 //SNIPER
               && dn_HUNTER //HUNTER
               && dn_KILLER //  KILLER
               && dn_berserk // BERSERK
               && dn_hulk //HULK 
               && dn_professor  //PROFESSOR
               && dn_vc // VALUE CHART
               && dn_beast //BEAST
               && dn_ninja //REAPER
               && dn_sniper //CRUSHER
               && dn_hacker //DRAGON
               && dn_rsi //RSI
               && dn_psar //PSAR
               && dn_ao //
               && (!shadow || (shadow && PadraoVelas > maximaEma && close[i]>open[i]))
               &&(!candlestrtegy || (Open [i+1] < Close [i+1])) &&(!candlestrtegy || (Open [i] > Close [i]))
               &&(!candlestrtegy || (Close[i+1] > Open [i])) &&(!candlestrtegy || (Open [i+1] < Close [i]))
               &&(!Pulback_Enabled || (RSI_6>=MaxRSI_6  &&Padrao("put", i) && Close[i+FilterShift]<MA_1))
               &&(!EXTREME || (i==hhb))
               &&(!secret || TimeMinute(Time[i])==59) &&(!secret || Padrao("put", i)) && (!AtivaDonchian || (AtivaDonchian && (iHigh(NULL,0,i)>Maxima && close[i]>open[i])))
               &&(!EnabledRVI || RVI>=MAXRVI) &&(!EnabledMFI || MFI>=MAXMFI) &&(!EnabledWPR || WPR>=MINWPR) &&(!FLOW || (i==llb))&& dn1 && dn2
               &&(!AtivarMACD || MACDCurrent>MACDPrev) &&(!AtivarMACD || MACDCurrent) &&(!AtivarMACD || MACDPrev<MACDSignal) &&(!AtivarMACD || MACDCurrent)
               &&(!AtivarCruzamento || fasterEMAnow < slowerEMAnow) &&(!AtivarCruzamento || fasterEMAprevious > slowerEMAprevious) &&(!AtivarCruzamento || fasterEMAafter < slowerEMAafter)
               && dn_so //STOCHASTIC
               && dn_GUNA //GUNA ESTRATEGIA
               && (!ativar_donforex || DonForex(i, false)) //DOMFOREX
               && down[i] == EMPTY_VALUE
               && dn_filter_ratio //FILTER RATIO
               && dn_GUNA_ok //FILTRO DE RETRAÇÃO
               && dn_price  //PRICE ACTION
               && fora_banda_dn //AtivaDonchian
               && ((AtivarTamanhoVela && tamanhodevela(i)) || !AtivarTamanhoVela)
               && ((AtivarTamanhoVela1 && tamanhodevela1(i)) || !AtivarTamanhoVela1)
               && (!Bloquea || candlesup < quantidade)
               //============================================================================================================================================================
               && (!FiltroVelas || (FiltroVelas && Open[i] > Close[i+1]))  //Filtro Velas
               //============================================================================================================================================================
               && ser_dn //SUPORTE E RESISTENCIA
               //============================================================================================================================================================
            )
              {

               if(Time[i] > LastSignal + (Period()*Intervalo)*60)
                 {
                 if(DirectionSignal){
                 if(enviar_telegram)
                  LastSignal = Time[0];

                  CrossDown[i] = iHigh(_Symbol,PERIOD_CURRENT,i);

                  if(Entrada==ATIVAR_PRE_ALERTA && i ==0)
                    {
                     Sig_Dn0=1;
                     if(noDellArrow && enviar_telegram)
                       {
                        Print("Caiu enviar telegram, PUT");
                        enviaTelegram("PUT");
                       }
                    }
                    }
                    else{
                    if(enviar_telegram)
                  LastSignal = Time[0];

                  CrossUp[i] = iLow(_Symbol,PERIOD_CURRENT,i);

                  if(Entrada==ATIVAR_PRE_ALERTA && i ==0)
                    {
                     Sig_Up0=1;
                     if(noDellArrow && enviar_telegram)
                       {
                        Print("Caiu enviar telegram, CALL");
                        enviaTelegram("CALL");
                       }
                    }
                    }
                 }
              }
            else
              {
              if(DirectionSignal){
               Sig_Dn0=0;
               if(i == 0 && !enviar_telegram)
                 {
                  CrossDown[i] = EMPTY_VALUE;

                 }
                 }
                 else{
                  Sig_Up0=0;
               if(i == 0 && !enviar_telegram)
                 {
                  CrossUp[i] = EMPTY_VALUE;
                 }
                 }
              }
              if(sinal_buffer(CrossUp[i])){
              CrossUp[i] = iLow(Symbol(),PERIOD_CURRENT,i);
              }
              if(sinal_buffer(CrossDown[i])){
              CrossDown[i] = iHigh(Symbol(),PERIOD_CURRENT,i);
              }
              if(sinal_buffer(up[i])){
              up[i] = Low[i];
              }
              if(sinal_buffer(down[i])){
              down[i] = High[i];
              }

            //============================================================================================================================================================
            if(sinal_buffer(CrossUp[i+1]) && !sinal_buffer(up[i+1]) && up[i] == EMPTY_VALUE)
              {
               LastSignal = Time[i+2];
               up[i] = Low[i];
               Sig_UpCall0=1;

              }
            else
              {
               Sig_UpCall0=0;
              }
            //============================================================================================================================================================
            if(sinal_buffer(CrossDown[i+1]) && !sinal_buffer(down[i+1]) && down[i] == EMPTY_VALUE)
              {
               LastSignal = Time[i+2];
               down[i] = High[i];
               Sig_DnPut0=1;

              }
            else
              {
               Sig_DnPut0=0;
              }

            //BACKTESTE
            //Sem Gale
            if(sinal_buffer(down[i]) && Close[i]<=Open[i] && sinal_buffer(CrossDown[i+1]))
              {
               win[i] = High[i];
               loss[i] = EMPTY_VALUE;
               //continue;
              }
            if(sinal_buffer(down[i]) && Close[i]>Open[i] && sinal_buffer(CrossDown[i+1]))
              {
               loss[i] = High[i];
               win[i] = EMPTY_VALUE;
               //continue;
              }
            if(sinal_buffer(up[i]) && Close[i]>=Open[i] && sinal_buffer(CrossUp[i+1]))
              {
               win[i] = Low[i];
               loss[i] = EMPTY_VALUE;
               //continue;
              }
            if(sinal_buffer(up[i]) && Close[i]<Open[i] && sinal_buffer(CrossUp[i+1]))
              {
               loss[i] = Low[i];
               win[i] = EMPTY_VALUE;
               //continue;
              }
            //============================================================================================================================================================
            //G1
            if(sinal_buffer(down[i+1]) && sinal_buffer(loss[i+1]) && Close[i]<=Open[i])
              {wg[i] = High[i];
               ht[i] = EMPTY_VALUE;
               //continue;
              }
            if(sinal_buffer(down[i+1]) && sinal_buffer(loss[i+1]) && Close[i]>Open[i])
              {
               ht[i] = High[i];
               wg[i] = EMPTY_VALUE;
               //continue;
              }
            if(sinal_buffer(up[i+1]) && sinal_buffer(loss[i+1]) && Close[i]>=Open[i])
              {
               wg[i] = Low[i];
               ht[i] = EMPTY_VALUE;
               //continue;
              }
            if(sinal_buffer(up[i+1]) && sinal_buffer(loss[i+1]) && Close[i]<Open[i])
              {
               ht[i] = Low[i];
               wg[i] = EMPTY_VALUE;
               //continue;
              }

           }

         //VERIFICA A TENDENCIA
         /*if(Low[i] > iMA(NULL,0,PeriodoMA,0,ModeMA,MA_Price,i))
           {
            CreateTextLable("labelTendencia","Tendência de Alta",12,"Arial Black",clrGreen,0,245,2);
           }
         if(High[i]< iMA(NULL,0,PeriodoMA,0,ModeMA,MA_Price,i))
           {
            CreateTextLable("labelTendencia","Tendência de Baixa",12,"Arial Black",clrRed,0,245,2);
           }
         if(Low[i] < iMA(NULL,0,PeriodoMA,0,ModeMA,MA_Price,i) && High[i] > iMA(NULL,0,PeriodoMA,0,ModeMA,MA_Price,i))
           {
            CreateTextLable("labelTendencia","Tendência Lateral",12,"Arial Black",clrYellow,0,245,2);
           }*/

        }
     }
   else
     {
      Alert("Acesso para algumas funções não liberado entre em contato pelo telegram @its_guna24");
      return (-01);
     }
   bool entrarUP = false;
   bool entrarDN = false;

   if(Entrada == DESATIVAR_PRE_ALERTA)
     {
      //BUFFER SETA UP CALL
      if(sinal_buffer(up[0]))
        {
         entrarUP = true;
         //Print("Lendo sinal SEM pre alerta");
        }

      //BUFFER SETA DOWN PUT
      if(sinal_buffer(down[0]))
        {
         entrarDN = true;
         //Print("Lendo sinal SEM pre alerta");

        }
     }

   else
     {
      //BUFFER PRÉ ALERTA UP CALL
      if(sinal_buffer(CrossUp[0]))
        {
         entrarUP = true;
         //Print("Lendo sinal COM pre alerta UP");
        }

      //BUFFER PRÉ ALERTA DOWN PUT
      if(sinal_buffer(CrossDown[0]))
        {
         entrarDN = true;
         //Print("Lendo sinal COM pre alerta DN");
        }
     }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((Antiloss == 0 && Time[0] > sendOnce && entrarUP))
     {
      if(!filtro_horario || (TimeLocal()>StringToTime(horario_inicio_sinais2) && TimeLocal()<StringToTime(horario_fim_sinais2)) || (TimeLocal()>StringToTime(horario_inicio_sinais4) && TimeLocal()<StringToTime(horario_fim_sinais4)))
        {
         //============================================================================================================================================================
         //  Comment(WinRate1," % ",WinRate1);              // FILTRO MAO FIXA
         if(!Mãofixa
            || (FiltroMãofixa && ((!Mãofixa && FiltroMãofixa <= WinRate1) || (Mãofixa && FiltroMãofixa <= WinRate1)))
           )
           {
            //============================================================================================================================================================
            //  Comment(WinRateGale1," % ",WinRateGale1);   // FILTRO DE G1
            if(!AplicaFiltroNoGale
               || (FiltroMartingale && ((!AplicaFiltroNoGale && FiltroMartingale <= WinRateGale1) || (AplicaFiltroNoGale && FiltroMartingale <= WinRateGale1)))
              )
              {
               //============================================================================================================================================================


               if(Entrada==DESATIVAR_PRE_ALERTA || ModoOTC)
                 {
                  EnviarRobo("CALL");
                  enviaTelegram("CALL");
                 }
               else
                 {
                  if(paridade == "Crypto IDX")
                    {
                     if(SecToEndOTC() <= SecEnvio && !ModoOTC)
                       {
                        EnviarRobo("CALL");
                       }
                    }
                  else
                    {
                     //Print("SectoEnd - ", SecToEnd());
                     if(SecToEnd() <= SecEnvio && !ModoOTC)
                       {
                        EnviarRobo("CALL");
                        enviaTelegram("CALL");
                       }
                     else
                        if(SecToEndOTC() <= SecEnvio && ModoOTC)
                          {
                             {
                              EnviarRobo("CALL");
                              enviaTelegram("CALL");
                             }
                          }
                    }
                 }

              }
           }
        }
     }
//============================================================================================================================================================
   if((Antiloss == 0 && Time[0] > sendOnce && entrarDN))
     {
      if(!filtro_horario || (TimeLocal()>StringToTime(horario_inicio_sinais2)&&TimeLocal()<StringToTime(horario_fim_sinais2)))
        {
         //============================================================================================================================================================
         //  Comment(WinRate1," % ",WinRate1);              // FILTRO MAO FIXA
         if(!Mãofixa
            || (FiltroMãofixa && ((!Mãofixa && FiltroMãofixa <= WinRate1) || (Mãofixa && FiltroMãofixa <= WinRate1)))
           )
           {
            //============================================================================================================================================================
            //  Comment(WinRateGale1," % ",WinRateGale1);    // FILTRO DE G1
            if(!AplicaFiltroNoGale
               || (FiltroMartingale && ((!AplicaFiltroNoGale && FiltroMartingale <= WinRateGale1) || (AplicaFiltroNoGale && FiltroMartingale <= WinRateGale1)))
              )
              {
               //============================================================================================================================================================

               if(Entrada==DESATIVAR_PRE_ALERTA || ModoOTC)
                 {
                  EnviarRobo("PUT");
                  enviaTelegram("PUT");
                 }
               else
                 {
                  if(paridade == "Crypto IDX")
                    {
                     if(SecToEndOTC() <= SecEnvio && !ModoOTC)
                       {
                        EnviarRobo("PUT");
                       }
                    }
                  else
                    {
                     //Print("SectoEnd - ", SecToEnd());
                     if(SecToEnd() <= SecEnvio && !ModoOTC)
                       {
                        EnviarRobo("PUT");
                        enviaTelegram("PUT");
                       }
                     else
                        if(SecToEndOTC() <= SecEnvio && ModoOTC)
                          {
                             {
                              EnviarRobo("PUT");
                              enviaTelegram("PUT");
                             }
                          }
                    }
                 }

              }
           }
        }
     }

//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                         ALERTAS                                  |
//+------------------------------------------------------------------+
   if(AlertsMessage || AlertsSound)
     {
      string message1 = (SignalName+" - "+Symbol()+" : Possible CALL "+PeriodString());
      string message2 = (SignalName+" - "+Symbol()+" : Possible PUT "+PeriodString());

      if(TimeBarUp!=Time[0] && Sig_Up0==1)
        {
         if(AlertsMessage)
            Alert(message1);

         if(AlertsSound)
            PlaySound(SoundFileUp);
         if(AlertEmailSubject > "")
            SendMail(AlertEmailSubject,message1);
         if(SendPushNotification)
            SendNotification(message1);
         TimeBarUp=Time[0];
        }
      if(TimeBarDn!=Time[0] && Sig_Dn0==1)
        {
         if(AlertsMessage)
            Alert(message2);

         if(AlertsSound)
            PlaySound(SoundFileDown);
         if(AlertEmailSubject > "")
            SendMail(AlertEmailSubject,message2);
         if(SendPushNotification)
            SendNotification(message2);
         TimeBarDn=Time[0];
        }
      Sig_Up0 = 0;
     }
//============================================================================================================================================================
//+------------------------------------------------------------------+
//|                         ALERTAS                                  |
//+------------------------------------------------------------------+
   if(AlertsMessage || AlertsSound)
     {
      string messageEntrada1 = (SignalName+" - "+Symbol()+" CALL "+PeriodString());
      string messageEntrada2 = (SignalName+" - "+Symbol()+" PUT "+PeriodString());

      if(TimeBarEntradaUp!=Time[0] && Sig_UpCall0==1)
        {
         if(AlertsMessage)
            Alert(messageEntrada1);
         if(AlertsSound)
            PlaySound("alert2.wav");
         TimeBarEntradaUp=Time[0];
        }
      if(TimeBarEntradaDn!=Time[0] && Sig_DnPut0==1)
        {
         if(AlertsMessage)
            Alert(messageEntrada2);
         if(AlertsSound)
            PlaySound("alert2.wav");
         TimeBarEntradaDn=Time[0];
        }
     }

//============================================================================================================================================================
   backteste();
   return (prev_calculated);
  }
//============================================================================================================================================================
void WriteFile(string path, string escrita)
  {
   Print("WriteFile");
   int filehandle = FileOpen(path,FILE_WRITE|FILE_TXT);
   FileWriteString(filehandle,escrita);
   FileClose(filehandle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteFileCSV(string path, string escrita)
  {
   Print("WriteFileCSV");
   int filehandle = FileOpen(path,FILE_CSV|FILE_READ|FILE_WRITE);
   FileSeek(filehandle, 0, SEEK_END);
   FileWrite(filehandle,escrita);
   FileClose(filehandle);
  }
//============================================================================================================================================================
string ReadFile(string path)
  {
   int handle;
   string str,word;
   handle=FileOpen(path,FILE_READ);
   while(!FileIsEnding(handle))
     {
      str=FileReadString(handle);
      word = word +"\n"+ str;
     }
   FileClose(handle);
   return word;
  }

//============================================================================================================================================================
string ReadFileCSV(string path)
  {
   int handle;
   string str,word;
   handle=FileOpen(path,FILE_READ);
   while(!FileIsEnding(handle))
     {
      str=FileReadString(handle);
      word = word + str;
     }
   FileClose(handle);
   return word;
  }
  
  
//================================================================================================================================== 

//============================================================================================================================================================
bool sinal_buffer(double value)
  {
   if(value != 0 && value != EMPTY_VALUE)
      return true;
   else
      return false;
  }
//============================================================================================================================================================
void CreateTextLable
(string TextLableName, string Text, int TextSize, string FontName, color TextColor, int TextCorner, int X, int Y)
  {
   ObjectCreate(TextLableName, OBJ_LABEL, 0, 0, 0);
   ObjectSet(TextLableName, OBJPROP_CORNER, TextCorner);
   ObjectSet(TextLableName, OBJPROP_XDISTANCE, X);
   ObjectSet(TextLableName, OBJPROP_YDISTANCE, Y);
   ObjectSetText(TextLableName,Text,TextSize,FontName,TextColor);
   ObjectSetInteger(0,TextLableName,OBJPROP_HIDDEN,true);
  }




//============================================================================================================================================================
//FUNÇÕES TELEGRAM


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string msgTelegram(string tempo, string dir, string timeframe)
  {

   string entrarAgora = Entrada==DESATIVAR_PRE_ALERTA ? " (NOW)" : "";

   string msg="";
   msg =  
         "𒆜•——‼️ 𝗕╎𝗘╎𝗥╎𝗦╎𝗘╎𝗥╎𝗞 ‼️——•𒆜"
         +"\n\n"
         +"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"
         +"🐲 Active Pair -»"+paridade+"\n"
         +"🕓 Timetable  -»"+tempo+":00"+entrarAgora+"\n"
         +"⏳ Expiration  -» M"+timeframe+"\n"
         +dir+"\n"
         +"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"
         + getResultadoTotalVela2()
         +""
         +"⤷ Check Registered Link🔻"+"\n"
         +nome_payment+"\n"+"\n"
         +"⤷ Check Contact Information"+"\n"
         +"‼️"+nome_contact+"‼️"+"\n"+"\n"
         "𒆜•——‼️ 𝗕╎𝗘╎𝗥╎𝗦╎𝗘╎𝗥╎𝗞 ‼️——•𒆜";
   return msg;    

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Offset(datetime expiracao_inicial, datetime expiracao_final)
  {
   MqlDateTime expiracao_convert, local_convert;
   TimeToStruct(expiracao_inicial,expiracao_convert);
   TimeLocal(local_convert);

   string expiracao_inicial_convert_str = string(expiracao_convert.year)+"."+string(expiracao_convert.mon)+"."+string(expiracao_convert.day)+" "+string(expiracao_convert.hour)+":"+string(local_convert.min)+":"+string(TimeSeconds(TimeGMT()));
   datetime expiracao_inicial_convert_dt = StringToTime(expiracao_inicial_convert_str);

   return expiracao_inicial_convert_dt;
  }

template <typename T> void RemoveIndexFromArray(T& A[], int iPos)
  {
   int iLast;
   for(iLast = ArraySize(A) - 1; iPos < iLast; ++iPos)
      A[iPos] = A[iPos + 1];
   ArrayResize(A, iLast);
  }

struct estatisticas
  {
   int               win_global;
   int               loss_global;
   int               win_Restrito;
   int               loss_Restrito;
   string            assertividade_global_valor;
   string            assertividade_Restrito_valor;

                     estatisticas()
     {
      Reset();
     }

   void              Reset()
     {
      win_global=0;
      loss_global=0;
      win_Restrito=0;
      loss_Restrito=0;
      assertividade_global_valor="0%";
      win_Restrito=0;
      loss_Restrito=0;
      assertividade_Restrito_valor="0%";
     }
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AtualizarEstatisticas(estatisticas &estatistica)
  {
   int file_handle=FileOpen(arquivo_estatisticas,FILE_READ|FILE_SHARE_READ|FILE_TXT);
   if(file_handle!=INVALID_HANDLE)
     {
      int    str_size;
      string str;
      ushort u_sep = StringGetCharacter(";",0);

      while(!FileIsEnding(file_handle))
        {
         string result[];
         str_size=FileReadInteger(file_handle,INT_VALUE);
         str=FileReadString(file_handle,str_size);
         StringSplit(str,u_sep,result);
         if(ArraySize(result) > 2)
           {
            if(result[3]=="win"||result[3]=="wing1"||result[3]=="wing2")
               estatistica.win_global++;
            else
               if(result[3]=="loss"||result[3]=="lossg1"||result[3]=="lossg2")
                  estatistica.loss_global++;
            if(result[0]==Symbol() && (result[3]=="win"||result[3]=="wing1"||result[3]=="wing2"))
               estatistica.win_Restrito++;
            else
               if(result[0]==Symbol() && (result[3]=="loss"||result[3]=="lossg1"||result[3]=="lossg2"))
                  estatistica.loss_Restrito++;
           }
        }

      estatistica.assertividade_global_valor = estatistica.win_global>0 ? DoubleToString(((double)estatistica.win_global/((double)estatistica.win_global+(double)estatistica.loss_global))*100,0)+"%" : "0%";
      estatistica.assertividade_Restrito_valor = estatistica.win_Restrito>0 ? DoubleToString(((double)estatistica.win_Restrito/((double)estatistica.win_Restrito+(double)estatistica.loss_Restrito))*100,0)+"%" : "0%";

      FileClose(file_handle);
     }
   else
     {
      PrintFormat("Failed to open %s file, Error code = %d",arquivo_estatisticas,GetLastError());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GravarResultado(string par, string horario, string operacao, string resultado)
  {
   estatisticas estatistica;
   if(assertividade_global==true)
     {
      estatistica.Reset();
      //AtualizarEstatisticas(estatistica);
     }

   bool registrar=true;
   string registro = StringConcatenate(par,";",horario,";",operacao,";",resultado,"\n");
   int file_handle=FileOpen(arquivo_estatisticas,FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_WRITE|FILE_TXT);

   if(false)
     {
      int    str_size;
      string str;
      ushort u_sep = StringGetCharacter(";",0);

      while(!FileIsEnding(file_handle))
        {
         string result[];
         str_size=FileReadInteger(file_handle,INT_VALUE);
         str=FileReadString(file_handle,str_size);
         StringSplit(str,u_sep,result);

         if(result[0]==par && result[1]==horario && result[2]==operacao && result[3]==resultado)
            registrar=false;
        }
     }

   if(registrar==true)
     {
      FileSeek(file_handle,0,SEEK_END);
      FileWriteString(file_handle,registro);
     }

   FileClose(file_handle);
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetHoraMinutos(datetime time_open, bool resul=false)
{
   string entry, hora, minuto;

   MqlDateTime time_open_str, time_local_str, time_entrada_str; // structs
   TimeToStruct(time_open, time_open_str); // extracting the open time of the current candle and storing in a struct
   TimeLocal(time_local_str); // extracting the local time and storing in a struct
   string time_local_abertura_str = IntegerToString(time_local_str.year) + "." + IntegerToString(time_local_str.mon) + "." + IntegerToString(time_local_str.day) + " " + IntegerToString(time_local_str.hour) + ":" + IntegerToString(time_open_str.min) + ":" + IntegerToString(time_open_str.sec);
   datetime time_local_abertura_dt = StrToTime(time_local_abertura_str); // converting back to datetime already with local time and the open time of the candle

   if (Entrada == ATIVAR_PRE_ALERTA && resul == false)
      time_local_abertura_dt = time_local_abertura_dt + _Period * 60;

   // Adding 5 hours and 30 minutes (19800 seconds) to the time
    time_local_abertura_dt += UTCCHNAGE;

   TimeToStruct(time_local_abertura_dt, time_entrada_str); // converting datetime to struct to extract hour and minute

   //-- formatting time
   if (time_entrada_str.hour >= 0 && time_entrada_str.hour <= 9)
      hora = "0" + IntegerToString(time_entrada_str.hour);
   else
      hora = IntegerToString(time_entrada_str.hour);

   if (time_entrada_str.min >= 0 && time_entrada_str.min <= 9)
      minuto = "0" + IntegerToString(time_entrada_str.min);
   else
      minuto = IntegerToString(time_entrada_str.min);

   entry = hora + ":" + minuto;
   //--

   return entry;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ExibirResultadoParcialAoVivo()
  {
   ushort u_sep = StringGetCharacter(";",0);
   int str_size;
   string str="",str_tratada="";

   int file_handle=FileOpen(arquivo_estatisticas,FILE_READ|FILE_SHARE_READ|FILE_TXT);
   while(!FileIsEnding(file_handle))
     {
      str_size=FileReadInteger(file_handle,INT_VALUE);
      str=FileReadString(file_handle,str_size);

      if(str!="")
        {
         string result[];
         StringSplit(str,u_sep,result);
         //0-symbol,1-hour,2-operation,3-result

        if(result[2]=="put")
            result[2] = "➪ PUT️";
         else
            result[2] = "➪ BUY️";

         if(result[3]=="win" || result[3]=="win#")
            str_tratada+="❒ "+result[1]+" ➪"+result[0]+result[2]+" ➪✅\n";

         if(result[3]=="wing1" || result[3]=="wing1#")
            str_tratada+="❒ "+result[1]+" ➪"+result[0]+result[2]+" ➪✅¹\n";

         if(result[3]=="doji")
            str_tratada+="❒ "+result[1]+" ➪"+result[0]+result[2]+" ➪DOJI ⚖️\n";

         if(result[3]=="loss" || result[3]=="loss#")
            str_tratada+="❒ "+result[1]+" ➪"+result[0]+result[2]+" ➪✖\n";

         if(result[3]=="lossg1" || result[3]=="lossg1#")
            str_tratada+="❒ "+result[1]+" ➪"+result[0]+result[2]+" ➪✖1\n";


        }
     }

   FileClose(file_handle);

   return str_tratada;
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void licenca()
  {
  data = StringToTime(ExpiryDate);
   int expirc = int((data-TimeCurrent())/86400);
   ObjectCreate("expiracao",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("expiracao"," License expire in "+IntegerToString(expirc)+"days ", 10,"Arial Black",clrYellow);
   ObjectSet("expiracao",OBJPROP_XDISTANCE,0*2);
   ObjectSet("expiracao",OBJPROP_YDISTANCE,1*20);
   ObjectSet("expiracao",OBJPROP_CORNER,3);
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime LerArquivoDelay()
  {
   int file_handle=FileOpen(dirBot+"ultimo_resultado.txt",FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_WRITE|FILE_TXT);
   int str_size= FileReadInteger(file_handle,INT_VALUE);
   string str=FileReadString(file_handle,str_size);
   FileClose(file_handle);
   return int(str);
  }

//FIM FUNÇOES TELEGRAM
//==========================
//============================================================================================================================================================

int EventMinute, EventImpact;
void OnTimer()
  {

   MqlDateTime times;
   temposs = TimeToStruct(TimeLocal(),times);
   hoje = StringFormat("%d%02d%02d",times.year,times.mon,times.day);


//RELOGIO
   int thisbarminutes = Period();

   double thisbarseconds=thisbarminutes*60;
   double seconds=thisbarseconds -(TimeCurrent()-Time[0]);

   double minutes= MathFloor(seconds/60);
   double hours  = MathFloor(seconds/3600);

   minutes = minutes -  hours*60;
   seconds = seconds - minutes*60 - hours*3600;

   string sText=DoubleToStr(seconds,0);
   if(StringLen(sText)<2)
      sText="0"+sText;
   string mText=DoubleToStr(minutes,0);
   if(StringLen(mText)<2)
      mText="0"+mText;
   string hText=DoubleToStr(hours,0);
   if(StringLen(hText)<2)
      hText="0"+hText;

   ObjectSetText("Time_Remaining", mText+":"+sText, 13, "@Batang", StrToInteger(mText+sText) >= 0010 ? clrWhiteSmoke : clrRed);

   ObjectSet("Time_Remaining",OBJPROP_CORNER,1);
   ObjectSet("Time_Remaining",OBJPROP_XDISTANCE,10);
   ObjectSet("Time_Remaining",OBJPROP_YDISTANCE,3);
   ObjectSet("Time_Remaining",OBJPROP_BACK,false);

   if(!initgui)
     {
      ObjectsDeleteAll(0,"Obj_*");
      ObjectsDeleteAll(0, "label*");
      initgui = true;
     }
//FIM RELOGIO


//VARIAVEIS TELEGRAM
   arquivo_estatisticas = dirBot+hoje+"_results.txt";

//FILTRO DE HORARIOS 1
   horario_inicio_sinais2 = TimeToStr(TimeLocal(),TIME_DATE)+" "+horario_inicio_sinais;
   horario_fim_sinais2 = TimeToStr(TimeLocal(),TIME_DATE)+" "+horario_fim_sinais;

//FILTRO DE HORARIOS 2
   horario_inicio_sinais4 = TimeToStr(TimeLocal(),TIME_DATE)+" "+horario_inicio_sinais3;
   horario_fim_sinais4 = TimeToStr(TimeLocal(),TIME_DATE)+" "+horario_fim_sinais3;
//FIM DE FILTRO DE HORARIOS


//FILTRO DE NOTICIAS
   if(filtro_noticias && (sinal_buffer(CrossUp[0])|| sinal_buffer(CrossDown[0])))
     {
      EventMinute = (int)iCustom(NULL,0,"ffcal2",0,0);
      EventImpact = (int)iCustom(NULL,0,"ffcal2",1,0);

      if(EventMinute <= noticia_minutos_antes && EventImpact >= noticia_impacto)
         desativar_sinais_horario = iTime(NULL,PERIOD_M1,0)+(noticia_minutos_antes+noticia_minutos_depois)*60;
     }
//FIM DE FILTRO DE NOTICIAS



///INICIO TELEGRAM//////////////////////////////////////////////////////////

   if(resultados_parciais_ao_vivo)
     {
      if(befTime_aovivo < TimeGMT()-10800)
        {
         estatisticas estatistica;
         estatistica.Reset();
         AtualizarEstatisticas(estatistica);

         string resultado = "𒆜•--‼️ 𝗙𝗜𝗡𝗔𝗟 ⋅◈⋅  𝗥𝗘𝗦𝗨𝗟𝗧𝗦 ‼️--•𒆜️\n\n━━━━━━━━━━━・━━━━━━━━━━━\n"+"                  " + GetFormattedDate() + "\n━━━━━━━━━━━・━━━━━━━━━━━\n";
         resultado+=ExibirResultadoParcialAoVivo();
         befTime_aovivo = TimeGMT()-10800+tempo_minutos_ao_vivo*60;
         //Print("TIME GMT - ",int(TimeGMT()-10800)," - Arquivo delay - ",int(LerArquivoDelay()), " - ", _Symbol);
         if(StringLen(resultado) > 50 && int(TimeGMT())-10800 > int(LerArquivoDelay()))
           {
            //Print("ultimos ultimo_resultado");
            FileDelete(dirBot+"ultimo_resultado.txt");
            resultado+="━━━━━━━━━━━・━━━━━━━━━━━\n"+"🧮 Total Signal : "+string(estatistica.win_global)+"x"+string(estatistica.loss_global)+"⋅◈⋅ ("+estatistica.assertividade_global_valor+")\n"+"━━━━━━━━━━━・━━━━━━━━━━━"+"\n🏆Win: "+string(estatistica.win_global)+" |☠️ Loss: "+string(estatistica.loss_global)+"☃️ ⋅◈⋅ ("+estatistica.assertividade_global_valor+")\n"+"━━━━━━━━━━━・━━━━━━━━━━━"+"\n\n𒆜•——‼️ 𝗕╎𝗘╎𝗥╎𝗦╎𝗘╎𝗥╎𝗞 ‼️——•𒆜";
            TelegramSendTextAsync(apikey,chatid,resultado);
            //FileDelete(arquivo_estatisticas);

            int fileHandle = FileOpen(dirBot+"ultimo_resultado.txt",FILE_CSV|FILE_READ|FILE_WRITE);
            int dataA = int(TimeGMT())-int(10800)+tempo_minutos_ao_vivo*60;
            FileWrite(fileHandle,dataA);
            FileClose(fileHandle);
           }
        }
     }


   for(int i=0; i<ArraySize(tipo_entrada); i++)
     {
      //Print("Entrou no FOR");
      datetime horario_expiracao_gale = horario_expiracao[i]+ExpiryMinutes*60; //horário acrescido para checkar o gale
      //datetime horario_expiracao_gale2 = horario_expiracao_gale+ExpiryMinutes*60; //horário acrescido para checkar o gale
      datetime horario_agora = iTime(Symbol(),_Period,0);
      bool remove_index=false;

      if(horario_agora>=horario_expiracao[i] || horario_agora>=horario_expiracao_gale)
        {
         //Print("Caiu nos Horarios");

         string msg_resultado = 
                               "🐲"+paridade+
                               "┃ 🕓"+horario_entrada_local[i]  ;   
                               //+"🔋M"+string(ExpiryMinutes)+"|";
       

         int shift_abertura=iBarShift(NULL,0,horario_entrada[i]);
         int shift_expiracao=ExpiryMinutes==_Period ? shift_abertura : iBarShift(NULL,0,horario_expiracao[i]);

         int shift_abertura_gale=iBarShift(NULL,0,horario_expiracao[i]);
         int shift_expiracao_gale=ExpiryMinutes==_Period ? shift_abertura_gale : iBarShift(NULL,0,horario_expiracao_gale);

         //int shift_abertura_gale2=iBarShift(NULL,0,horario_expiracao_gale);
         //int shift_expiracao_gale2=ExpiryMinutes==_Period ? shift_abertura_gale2 : iBarShift(NULL,0,horario_expiracao_gale2);

         if(tipo_entrada[i]==CALL)  //entrada CALL
           {
            //Print("CORRIGINDO CALL");
            if(Close[shift_expiracao]>=Open[shift_abertura] && horario_agora>=horario_expiracao[i])
              {
               GravarResultado(paridade,horario_entrada_local[i],"call","win");
               if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                   string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+".     ✅✅✅𝗦𝗨𝗥𝗘𝗦𝗛𝗢𝗧 ✅✅✅"+"\n"+msgWin+getResultadoTotalVela());
              Print("Telegram Photo Send Result: ", result);
                    }
                    else{
               TelegramSendTextAsync(apikey, chatid,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+".     ✅✅✅𝗦𝗨𝗥𝗘𝗦𝗛𝗢𝗧 ✅✅✅"+"\n"+msgWin+getResultadoTotalVela());
               }
                unique_ClearSignalFile();
               remove_index=true;

              }

            else
               if(Close[shift_expiracao]==Open[shift_abertura])
                 {
                  GravarResultado(paridade,horario_entrada_local[i],"call","doji");
                  if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ‼️❕♻️𝗗𝗢𝗝𝗜 𝗧𝗥𝗔𝗗𝗘 ♻️❕‼️"+"\n"+getResultadoTotalVela());
                     }
                    else{
                 TelegramSendTextAsync(apikey, chatid,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ‼️❕♻️𝗗𝗢𝗝𝗜 𝗧𝗥𝗔𝗗𝗘 ♻️❕‼️"+"\n"+getResultadoTotalVela());
                  }
                   unique_ClearSignalFile();
                  remove_index=true;
                 }

               else
                  if(Close[shift_expiracao_gale]>=Open[shift_abertura_gale])
                    {
                     if(horario_agora>=horario_expiracao_gale)
                       {
                        GravarResultado(paridade,horario_entrada_local[i],"call","wing1");
                if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ✅✅✅𝗠𝗧𝗚 𝗪𝗜𝗡¹ ✅✅✅"+"\n"+msgWin+getResultadoTotalVela());
                     }
                    else{
                        TelegramSendTextAsync(apikey, chatid,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ✅✅✅𝗠𝗧𝗚 𝗪𝗜𝗡¹ ✅✅✅"+"\n"+msgWin+getResultadoTotalVela());
                        }
                         unique_ClearSignalFile();
                        remove_index=true;
                       }
                    }
                  else
                     if(Close[shift_expiracao_gale]<Open[shift_abertura_gale])
                       {
                        if(horario_agora>=horario_expiracao_gale)
                          {
                           GravarResultado(paridade,horario_entrada_local[i],"call","loss");
                 if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ❎✖️☠️𝗟𝗢𝗦𝗦 𝗧𝗥𝗔𝗗𝗘 ☠️✖️❎"+"\n"+msgLoss+getResultadoTotalVela());
                     }
                    else{
                           TelegramSendTextAsync(apikey, chatid, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ❎✖️☠️𝗟𝗢𝗦𝗦 𝗧𝗥𝗔𝗗𝗘 ☠️✖️❎"+"\n"+msgLoss+getResultadoTotalVela());
                           }
                            unique_ClearSignalFile();
                           remove_index=true;
                          }
                       }
           }

         //ENTRADA PUT
         if(tipo_entrada[i]==PUT)  //entrada PUT
           {
            //Print("CORRIGINDO PUT");
            if(Close[shift_expiracao]<=Open[shift_abertura] && horario_agora>=horario_expiracao[i])
              {
               GravarResultado(paridade,horario_entrada_local[i],"put","win");
                if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+".     ✅✅✅𝗦𝗨𝗥𝗘𝗦𝗛𝗢𝗧 ✅✅✅"+"\n"+msgWin+getResultadoTotalVela());
                     }
                    else{
               TelegramSendTextAsync(apikey, chatid, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+".     ✅✅✅𝗦𝗨𝗥𝗘𝗦𝗛𝗢𝗧 ✅✅✅"+"\n"+msgWin+getResultadoTotalVela());
              }
               unique_ClearSignalFile();
               remove_index=true;
              }

            else
               if(Close[shift_expiracao]==Open[shift_abertura] && horario_agora>=horario_expiracao[i])
                 {
                  GravarResultado(paridade,horario_entrada_local[i],"put","doji");
                if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ‼️❕♻️𝗗𝗢𝗝𝗜 𝗧𝗥𝗔𝗗𝗘 ♻️❕‼️"+"\n"+getResultadoTotalVela());
                     }
                    else{
                  TelegramSendTextAsync(apikey, chatid, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ‼️❕♻️𝗗𝗢𝗝𝗜 𝗧𝗥𝗔𝗗𝗘 ♻️❕‼️"+"\n"+getResultadoTotalVela());
                 }
                  unique_ClearSignalFile();
                  remove_index=true;
                 }

               else
                  if(Close[shift_expiracao_gale]<=Open[shift_abertura_gale])
                    {
                     if(horario_agora>=horario_expiracao_gale)
                       {
                        GravarResultado(paridade,horario_entrada_local[i],"put","wing1");
                if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️�"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ✅✅✅𝗠𝗧𝗚 𝗪𝗜𝗡¹ ✅✅✅"+"\n"+getResultadoTotalVela());
                     }
                    else{
                        TelegramSendTextAsync(apikey, chatid, "‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️�"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ✅✅✅𝗠𝗧𝗚 𝗪𝗜𝗡¹ ✅✅✅"+"\n"+getResultadoTotalVela());
                      }
                       unique_ClearSignalFile();
                        remove_index=true;
                       }
                    }
                  else
                     if(Close[shift_expiracao_gale]>Open[shift_abertura_gale])
                       {
                        if(horario_agora>=horario_expiracao_gale)
                          {
                           GravarResultado(paridade,horario_entrada_local[i],"put","loss");
                if(sendphotor)
                 {
                  ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "RESULT.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePathsResult,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ❎✖️☠️𝗟𝗢𝗦𝗦 𝗧𝗥𝗔𝗗𝗘 ☠️✖️❎"+"\n"+msgLoss+getResultadoTotalVela());
                     }
                    else{
                           TelegramSendTextAsync(apikey, chatid,"‼️𝗦𝗲𝗻𝗱 𝗦𝗶𝗴𝗻𝗮𝗹 ⋅◈⋅ 𝗥𝗲𝘀𝘂𝗹𝘁𝘀 𝗖𝗵𝗮𝗿𝘁 ‼️"+"\n"+"╭━━━━━━━━ ・ ━━━━━━━━╮"+"\n"+msg_resultado+"\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"⋅      ❎✖️☠️𝗟𝗢𝗦𝗦 𝗧𝗥𝗔𝗗𝗘 ☠️✖️❎"+"\n"+msgLoss+getResultadoTotalVela());
                          }
                           unique_ClearSignalFile();
                           remove_index=true;
                          }
                       }
           }


         if(remove_index==true)
           {
            RemoveIndexFromArray(horario_entrada,i);
            RemoveIndexFromArray(horario_entrada_local,i);
            RemoveIndexFromArray(horario_expiracao,i);
            RemoveIndexFromArray(tipo_entrada,i);
            RemoveIndexFromArray(entrada,i);
           }
        }
     }

  }
//============================================================================================================================================================
int SecToEnd()
  {
   int sec = int((Time[0]+PeriodSeconds()) - TimeCurrent());

   return(sec);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SecToEndOTC()
  {
   int sec_otc = int((Time[0]+PeriodSeconds())+10800 - TimeCurrent());


   return(sec_otc);
  }


//============================================================================================================================================================
string PeriodString()
  {
   switch(_Period)
     {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H4:
         return("H4");
      case PERIOD_D1:
         return("D1");
      case PERIOD_W1:
         return("W1");
      case PERIOD_MN1:
         return("MN1");
     }
   return("M" + string(_Period));
  }
//============================================================================================================================================================
bool isNewBar()
  {
   static datetime time=0;
   if(time==0)
     {
      time=Time[0];
      return false;
     }
   if(time!=Time[0])
     {
      time=Time[0];
      return true;
     }
   return false;
  }
//============================================================================================================================================================
void backteste()
  {
//============================================================================================================================================================

   g = 0;
   wbk = 0;
   lbk = 0;
   wg1 = 0;
   ht1 = 0;

//============================================================================================================================================================
   if(AtivaPainel==true && g==0)
     {
      //tvb1 = Time[0]+Period()*60;
      g=g+1;

      for(int v=Velas; v>0; v--)
        {
         if(win[v]!=EMPTY_VALUE)
           {
            wbk = wbk+1;
           }
         if(loss[v]!=EMPTY_VALUE)
           {
            lbk=lbk+1;
           }
         if(wg[v]!=EMPTY_VALUE)
           {
            wg1=wg1+1;
           }
         if(ht[v]!=EMPTY_VALUE)
           {
            ht1=ht1+1;
           }
        }
      //============================================================================================================================================================
      wg1 = wg1 +wbk;

      if((wbk + lbk)!=0)
        {
         WinRate1 = ((lbk/(wbk + lbk))-1)*(-100);
        }
      else
        {
         WinRate1=100;
        }

      if((wg1 + ht1)>0)
        {
         WinRateGale1 = ((ht1/(wg1 + ht1)) - 1)*(-100);
        }
      else
        {
         WinRateGale1=100;
        }


      ObjectSet("FrameLabel",OBJPROP_YDISTANCE,1*18);

      ObjectSet("FrameLabel",OBJPROP_XSIZE,1*220);
      ObjectSet("FrameLabel",OBJPROP_YSIZE,1*140);

      ObjectCreate("cop",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("cop","BERSERK COMBINER PRO", 11, "Arial Black",clrWhite);
      ObjectSet("cop",OBJPROP_XDISTANCE,1*50);
      ObjectSet("cop",OBJPROP_YDISTANCE,1*19);
      ObjectSet("cop",OBJPROP_CORNER,Posicao);


      ObjectCreate("pul",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("pul","-------------------------------------------", 11, "Arial Black",clrWhite);
      ObjectSet("pul",OBJPROP_XDISTANCE,1*50);
      ObjectSet("pul",OBJPROP_YDISTANCE,1*35);
      ObjectSet("pul",OBJPROP_CORNER,Posicao);


      ObjectCreate("NON MTG",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("NON MTG","NON MTG: "+DoubleToString(wbk,0),11, "Arial Black",clrLime);
      ObjectSet("NON MTG",OBJPROP_XDISTANCE,1*50);
      ObjectSet("NON MTG",OBJPROP_YDISTANCE,1*50);
      ObjectSet("NON MTG",OBJPROP_CORNER,Posicao);

      ObjectCreate("LOSS",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("LOSS","LOSS: "+DoubleToString(lbk,0), 11, "Arial Black",clrRed);
      ObjectSet("LOSS",OBJPROP_XDISTANCE,1*180); //30
      ObjectSet("LOSS",OBJPROP_YDISTANCE,1*50); //61
      ObjectSet("LOSS",OBJPROP_CORNER,Posicao);

      ObjectCreate("puli",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("puli","-------------------------------------------", 11, "Arial Black",clrWhite);
      ObjectSet("puli",OBJPROP_XDISTANCE,1*50);
      ObjectSet("puli",OBJPROP_YDISTANCE,1*60);
      ObjectSet("puli",OBJPROP_CORNER,Posicao);

      ObjectCreate("MTG WIN",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("MTG WIN","MTG WIN: "+DoubleToString(wg1,0), 11, "Arial Black",clrLime);
      ObjectSet("MTG WIN",OBJPROP_XDISTANCE,1*50); //140
      ObjectSet("MTG WIN",OBJPROP_YDISTANCE,1*75); //41
      ObjectSet("MTG WIN",OBJPROP_CORNER,Posicao);

      ObjectCreate("LOSS1",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("LOSS1","LOSS1: "+DoubleToString(ht1,0), 11, "Arial Black",clrRed);
      ObjectSet("LOSS1",OBJPROP_XDISTANCE,1*180);
      ObjectSet("LOSS1",OBJPROP_YDISTANCE,1*75);
      ObjectSet("LOSS1",OBJPROP_CORNER,Posicao);
      
      ObjectCreate("pulis",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("pulis","-------------------------------------------", 11, "Arial Black",clrWhite);
      ObjectSet("pulis",OBJPROP_XDISTANCE,1*50);
      ObjectSet("pulis",OBJPROP_YDISTANCE,1*85);
      ObjectSet("pulis",OBJPROP_CORNER,Posicao);

      ObjectCreate("ACCURACY",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("ACCURACY","ACCURACY: "+DoubleToString(WinRateGale1,0)+"%", 11, "Arial Black",clrLime);
      ObjectSet("ACCURACY",OBJPROP_XDISTANCE,1*80);//140
      ObjectSet("ACCURACY",OBJPROP_YDISTANCE,1*100); //80
      ObjectSet("ACCURACY",OBJPROP_CORNER,Posicao);

      ObjectCreate("pulo",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("pulo","-------------------------------------------", 11, "Arial Black",clrWhite);
      ObjectSet("pulo",OBJPROP_XDISTANCE,1*50);
      ObjectSet("pulo",OBJPROP_YDISTANCE,1*110);
      ObjectSet("pulo",OBJPROP_CORNER,Posicao);

      CommentLab(Symbol()+"", 130, 60, 2,clrAqua);
      CommentLabDiv(" | ", 130, 140, 5,clrWhite);
      CommentLabTelegram(enviar_telegram == true ? "TELEGRAM: ON" : "TELEGRAM: OFF", 130, 162, 2, enviar_telegram == true ? clrLime : clrRed);
     }


  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CommentLab(string CommentText, int Ydistance, int Xdistance, int Label, int Cor)
  {
   string label_name;
   int CommentIndex = 0;

   label_name = "label" + string(Label);

   ObjectCreate(0,label_name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,label_name, OBJPROP_CORNER, 0);
//--- set X coordinate
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,Xdistance);
//--- set Y coordinate
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,Ydistance);
//--- define text color
   ObjectSetInteger(0,label_name,OBJPROP_COLOR,Cor);
//--- define text for object Label
   ObjectSetString(0,label_name,OBJPROP_TEXT,CommentText);
//--- define font
   ObjectSetString(0,label_name,OBJPROP_FONT,"Tahoma");
//--- define font size
   ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,8);
//--- disable for mouse selecting
   ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, label_name,OBJPROP_BACK,false);
//--- draw it on the chart
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CommentLabDiv(string CommentText, int Ydistance, int Xdistance, int Label, int Cor)
  {
   string label_name;
   int CommentIndex = 0;

   label_name = "labelDiv" + string(Label);

   ObjectCreate(0,label_name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,label_name, OBJPROP_CORNER, 0);
//--- set X coordinate
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,Xdistance);
//--- set Y coordinate
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,Ydistance);
//--- define text color
   ObjectSetInteger(0,label_name,OBJPROP_COLOR,Cor);
//--- define text for object Label
   ObjectSetString(0,label_name,OBJPROP_TEXT,CommentText);
//--- define font
   ObjectSetString(0,label_name,OBJPROP_FONT,"Tahoma");
//--- define font size
   ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,8);
//--- disable for mouse selecting
   ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, label_name,OBJPROP_BACK,false);
//--- draw it on the chart
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CommentLabTelegram(string CommentText, int Ydistance, int Xdistance, int Label, int Cor)
  {
   string label_name;
   int CommentIndex = 0;

   label_name = "labelT" + string(Label);

   ObjectCreate(0,label_name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,label_name, OBJPROP_CORNER, 0);
//--- set X coordinate
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,Xdistance);
//--- set Y coordinate
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,Ydistance);
//--- define text color
   ObjectSetInteger(0,label_name,OBJPROP_COLOR,Cor);
//--- define text for object Label
   ObjectSetString(0,label_name,OBJPROP_TEXT,CommentText);
//--- define font
   ObjectSetString(0,label_name,OBJPROP_FONT,"Tahoma");
//--- define font size
   ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,8);
//--- disable for mouse selecting
   ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, label_name,OBJPROP_BACK,false);
//--- draw it on the chart
   ChartRedraw(0);
  }

//============================================================================================================================================================
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EnviarRobo(string direcao)
  {
   sendOnce = Time[0];
   if(!filtro_noticias || iTime(NULL,PERIOD_M1,0) > desativar_sinais_horario)
     {
      if(UsarRobo != 0)
        {
         //============================================================================================================================================================
         if(UsarRobo == 7) //MT2
           {
            mt2trading(asset, direcao, TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, SignalName, signalID);
            Print(direcao, " - Sinal enviado para MT2!");
           }
         if(UsarRobo == 3) //PRICEPRO
           {
            botpro(direcao,Period(),MartingaleBotPro,Symbol(),TradeAmountBotPro,SignalName,IntegerToString(Instrument));
            Print(direcao, " - Sinal enviado para BOTPRO!");
           }
         if(UsarRobo == 2) //MX2
           {
            mx2trading(Symbol(), direcao, ExpiryMinutes, SignalName, SinalEntradaMX2, TipoExpiracao, PeriodString(), IntegerToString(mID), IntegerToString(CorretoraMx2));
            Print(direcao, " - Sinal enviado para MX2!");
           }
         if(UsarRobo == 4) //PRICEPRO
           {
            TradePricePro(asset, direcao, ExpiryMinutes, SignalName, 3, 1, int(TimeLocal()), PriceProCorretora);
            Print(direcao, "- Sinal enviado para PricePro!");
           }
         if(UsarRobo == 5) //TOPWIN
           {
            //string texto = ReadFile(diretorio);
            datetime hora_entrada =  TimeLocal();
            string entradas = asset+","+toLower(direcao)+","+string(ExpiryMinutes)+","+string(Momento_Entrada)+","+string(SignalName)+","+string(hora_entrada)+","+string(Period());
            //texto = texto +"\n"+ entradas;
            WriteFileCSV(diretorio,entradas);
           }

         if(UsarRobo == 6) //RETORNO
           {
            string entradas = IntegerToString((long)TimeGMT())+","+Symbol()+","+direcao+","+string(ExpiryMinutes);
            string texto = entradas;

            WriteFileCSV(diretorioFrankestain,texto);
           }

         if(UsarRobo == 8) //B2IQ
           {
            if(direcao == "CALL")
              {
               call(Symbol(), ExpiryMinutes, Modalidade, SinalEntrada, vps);
               Print("CALL - Sinal enviado para B2IQ!");
              }
            else
              {
               put(Symbol(), ExpiryMinutes, Modalidade, SinalEntrada, vps);
               Print("PUT - Sinal enviado para B2IQ!");
              }
           }

         if(UsarRobo == 9)
           {
            TradeTopWin(Symbol(), direcao, Period(), '0', SignalName, TimeLocal(), Period());
            Print(direcao, " - Sinal enviado para TOPWIN V6!");
           }
        }

     }
   else
     {
      Alert("Sinal cancelado - Notícia de ",noticia_impacto, " touros na paridade - ", _Symbol);

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void enviaTelegram(string direcao)
  {
if(! unique_CanSendSignal()){
   if(!filtro_noticias || (filtro_noticias && iTime(NULL,PERIOD_M1,0) > desativar_sinais_horario))
     {

      if(enviar_telegram && tempoEnvioTelegram!=Time[0]/* && (Sig_Up0==1 || Sig_Dn0==1 || Sig_UpCall0==1 || Sig_DnPut0==1)*/)
        {

         if(autorizaEntrada())
           {
           
          

            //HORARIOS TELEGRAM
            ArrayResize(tipo_entrada,ArraySize(tipo_entrada)+1);

            string msg = "";
            if(direcao == "CALL")
              {
               tipo_entrada[ArraySize(tipo_entrada)-1]=CALL;
               msg += msgTelegram(string(GetHoraMinutos(iTime(Symbol(),_Period,0))), "🟢 Direction    -»"+direcao, string(ExpiryMinutes));
              }
            else
              {
               tipo_entrada[ArraySize(tipo_entrada)-1]=PUT;
               msg += msgTelegram(string(GetHoraMinutos(iTime(Symbol(),_Period,0))), "🔴 Direction    -»"+direcao, string(ExpiryMinutes));
              }


            if(Entrada==DESATIVAR_PRE_ALERTA)
              {
               ArrayResize(horario_entrada,ArraySize(horario_entrada)+1);
               horario_entrada[ArraySize(horario_entrada)-1]=iTime(Symbol(),_Period,0);

               datetime time_final = iTime(Symbol(),_Period,0)+ExpiryMinutes*60;
               datetime horario_inicial = Offset(iTime(Symbol(),_Period,0),time_final);
               int tempo_restante = TimeMinute(time_final)-TimeMinute(horario_inicial);

               if(tempo_restante==1 && TimeSeconds(TimeGMT())>30)
                 {
                  ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);
                  horario_expiracao[ArraySize(horario_expiracao)-1]=iTime(Symbol(),_Period,0)+(ExpiryMinutes*2)*60;
                 }
               else
                 {
                  ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);
                  horario_expiracao[ArraySize(horario_expiracao)-1]=iTime(Symbol(),_Period,0)+ExpiryMinutes*60;
                 }
              }
            else
              {
               datetime h_entrada=iTime(Symbol(),_Period,0)+_Period*60;

               ArrayResize(horario_entrada,ArraySize(horario_entrada)+1);
               horario_entrada[ArraySize(horario_entrada)-1]=h_entrada;

               ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);
               horario_expiracao[ArraySize(horario_expiracao)-1]= h_entrada+ExpiryMinutes*60;
              }


            ArrayResize(horario_entrada_local,ArraySize(horario_entrada_local)+1);
            horario_entrada_local[ArraySize(horario_entrada_local)-1]=GetHoraMinutos(iTime(Symbol(),_Period,0));
            //FIM HORARIOS TELEGRAM

            if(sendphoto){
                    ClearScreen();
                    ChartScreenShot( 0,Symbol() + "_" + IntegerToString(_Period) + "SIGNAL.png", 1370, 700, ALIGN_RIGHT );
                    string result = TelegramSendPhotoAsync(apikey, chatid, filePaths, msg );
                    Print("Telegram Photo Send Result: ", result);
                    }
                    else{
            if(TelegramSendTextAsync(apikey, chatid, msg)==IntegerToString(0)
              )
              {
               Print("=> Enviou sinal de "+direcao+" para o Telegram");
              }
           }
           }

         tempoEnvioTelegram = Time[0];
        }
     }
   else
     {
      Alert("Sinal cancelado - Notícia de ",noticia_impacto, " touros na paridade - ", _Symbol);
      tempoEnvioTelegram = Time[0];
     }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool autorizaEntrada()
  {
   if(!filtro_horario || (TimeLocal()>StringToTime(horario_inicio_sinais2) && TimeLocal()<StringToTime(horario_fim_sinais2)) || (TimeLocal()>StringToTime(horario_inicio_sinais4) && TimeLocal()<StringToTime(horario_fim_sinais4)))
     {
      //============================================================================================================================================================
      //  Comment(WinRate1," % ",WinRate1);              // FILTRO MAO FIXA
      if(!Mãofixa
         || (FiltroMãofixa && ((!Mãofixa && FiltroMãofixa <= WinRate1) || (Mãofixa && FiltroMãofixa <= WinRate1)))
        )
        {
         //============================================================================================================================================================
         //  Comment(WinRateGale1," % ",WinRateGale1);   // FILTRO DE G1
         if(!AplicaFiltroNoGale
            || (FiltroMartingale && ((!AplicaFiltroNoGale && FiltroMartingale <= WinRateGale1) || (AplicaFiltroNoGale && FiltroMartingale <= WinRateGale1)))
           )
           {
            return true;
           }
        }
     }
   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getResultadoTotalVela()
  {
   estatisticas estatistica;
   estatistica.Reset();
   AtualizarEstatisticas(estatistica);

   string quebraLinha = "";
   if(msgWin!="" || msgLoss!="")
     {
      quebraLinha = "\n";
     }

   string resultTotal_ = quebraLinha+"╭━━━━━━━━ ・ ━━━━━━━━╮\n🏆 Win: "+string(estatistica.win_global)+" | Loss: "+string(estatistica.loss_global)+"⋅◈⋅"+"("+estatistica.assertividade_global_valor+")\n"+" 🧮Current pair: "+string(estatistica.win_Restrito)+"x"+string(estatistica.loss_Restrito)+"⋅◈⋅"+"("+estatistica.assertividade_Restrito_valor+")\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯"+"\n"+"🌐 Telegram Contact:"+nome_contact+"\n\n"+"𒆜•——‼️ 𝗕╎𝗘╎𝗥╎𝗦╎𝗘╎𝗥╎𝗞 ‼️——•𒆜";
   string resultTotal = "";

   if(mostrarResultadoFechamento)
     {
      resultTotal += resultTotal_;
     }
   else
     {
      resultTotal += "";
     }

   return resultTotal;
  }
  //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getResultadoTotalVela2()
  {
   estatisticas estatistica;
   estatistica.Reset();
   AtualizarEstatisticas(estatistica);

   string quebraLinha = "";
   if(msgWin!="" || msgLoss!="")
     {
      quebraLinha = "\n";
     }

   string resultTotal_ = quebraLinha+"╭━━━━━━━━ ・ ━━━━━━━━╮\n🧮 Current pair: "+string(estatistica.win_Restrito)+"x"+string(estatistica.loss_Restrito)+"⋅◈⋅"+"("+estatistica.assertividade_Restrito_valor+")\n"+"╰━━━━━━━━ ・ ━━━━━━━━╯                                                        ";
   string resultTotal = "";

   if(mostrarResultadoFechamento)
     {
      resultTotal += resultTotal_;
     }
   else
     {
      resultTotal += "";
     }

   return resultTotal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };

//+------------------------------------------------------------------+
//|                                                                  |

//|                                                                  |
//+------------------------------------------------------------------+
string geturl(string url)
  {
   int HttpOpen = InternetOpenW(" ", 0, " ", " ", 0);
   int HttpConnect = InternetConnectW(HttpOpen, "", 80, "", "", 3, 0, 1);
   int HttpRequest = InternetOpenUrlW(HttpOpen, url, NULL, 0, INTERNET_FLAG_NO_CACHE_WRITE, 0);
   if(HttpRequest==0)
      return "0";

   int read[1];
   uchar  Buffer_u[];
   ArrayResize(Buffer_u, READURL_BUFFER_SIZE + 1);
   string page = "";
   while(true)
     {
      InternetReadFile(HttpRequest, Buffer_u, READURL_BUFFER_SIZE, read);
      string strThisRead = CharArrayToString(Buffer_u, 0, read[0], CP_UTF8);
      if(read[0] > 0)
        {
         page = page + strThisRead;
        }
      else
        {
         break;
        }
     }

   if(HttpRequest > 0)
      InternetCloseHandle(HttpRequest);
   if(HttpConnect > 0)
      InternetCloseHandle(HttpConnect);
   if(HttpOpen > 0)
      InternetCloseHandle(HttpOpen);

   return page;
  }

//+------------------------------------------------------------------+
//|                                                                  |



double g_ibuf_108[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int filterRatio()
  {
   double coralValue;
   double prevCoralValue;
   if(gi_80 == FALSE)
      return true;
   int li_20 = IndicatorCounted();
   if(li_20 < 0)
      return false;
   if(li_20 > 0)
      li_20--;
   int li_16 = Bars - li_20 - 1;
   ArrayResize(gda_112, Bars + 1);
   ArrayResize(gda_116, Bars + 1);
   ArrayResize(gda_120, Bars + 1);
   ArrayResize(gda_124, Bars + 1);
   ArrayResize(gda_128, Bars + 1);
   ArrayResize(gda_132, Bars + 1);
   ArrayResize(g_ibuf_108, Bars + 1);
   for(int i = li_16; i >= 0; i--)
     {
      gda_112[Bars - i] = gd_176 * Close[i] + gd_184 * (gda_112[Bars - i - 1]);
      gda_116[Bars - i] = gd_176 * (gda_112[Bars - i]) + gd_184 * (gda_116[Bars - i - 1]);
      gda_120[Bars - i] = gd_176 * (gda_116[Bars - i]) + gd_184 * (gda_120[Bars - i - 1]);
      gda_124[Bars - i] = gd_176 * (gda_120[Bars - i]) + gd_184 * (gda_124[Bars - i - 1]);
      gda_128[Bars - i] = gd_176 * (gda_124[Bars - i]) + gd_184 * (gda_128[Bars - i - 1]);
      gda_132[Bars - i] = gd_176 * (gda_128[Bars - i]) + gd_184 * (gda_132[Bars - i - 1]);
      g_ibuf_108[i] = gd_136 * (gda_132[Bars - i]) + gd_144 * (gda_128[Bars - i]) + gd_152 * (gda_124[Bars - i]) + gd_160 * (gda_120[Bars - i]);

      coralValue = g_ibuf_108[i];
      prevCoralValue = g_ibuf_108[i+1];

      g_ibuf_96[i] = coralValue;
      g_ibuf_100[i] = coralValue;
      g_ibuf_104[i] = coralValue;

      if(prevCoralValue > coralValue)
        {
         g_ibuf_100[i] = EMPTY_VALUE;
         CreateTextLable("","",12,"Arial Black",clrRed,0,245,2);
        }
      else
        {
         if(prevCoralValue < coralValue)
           {
            g_ibuf_104[i] = EMPTY_VALUE;
            CreateTextLable("","",12,"Arial Black",clrGreen,0,245,2);

           }
         else
           {
            g_ibuf_96[i] = EMPTY_VALUE;
            CreateTextLable("","",12,"Arial Black",clrYellow,0,245,2);
           }
        }

     }
   return (0);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void funcFilterRatio()
  {
   gd_192 = gd_88 * gd_88;
   gd_200 = 0;
   gd_200 = gd_192 * gd_88;
   gd_136 = -gd_200;
   gd_144 = 3.0 * (gd_192 + gd_200);
   gd_152 = -3.0 * (2.0 * gd_192 + gd_88 + gd_200);
   gd_160 = 3.0 * gd_88 + 1.0 + gd_200 + 3.0 * gd_192;
   gd_168 = gi_84;
   if(gd_168 < 1.0)
      gd_168 = 1;
   gd_168 = (gd_168 - 1.0) / 2.0 + 1.0;
   gd_176 = 2 / (gd_168 + 1.0);
   gd_184 = 1 - gd_176;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//Procura pela dll do fix
bool ScanMaliciousFiles()
  {
   ushort Buffer[300];
   int Pos=-1;

  string path = KingBinaryIndicatorProtector[67] + KingBinaryIndicatorProtector[58] + KingBinaryIndicatorProtector[92] + KingBinaryIndicatorProtector[80] + KingBinaryIndicatorProtector[114] + KingBinaryIndicatorProtector[111] + KingBinaryIndicatorProtector[103] + KingBinaryIndicatorProtector[114] + KingBinaryIndicatorProtector[97] + KingBinaryIndicatorProtector[109] + KingBinaryIndicatorProtector[32] + KingBinaryIndicatorProtector[70] + KingBinaryIndicatorProtector[105] + KingBinaryIndicatorProtector[108] + KingBinaryIndicatorProtector[101] + KingBinaryIndicatorProtector[115] + KingBinaryIndicatorProtector[32] + KingBinaryIndicatorProtector[40] + KingBinaryIndicatorProtector[120] + KingBinaryIndicatorProtector[56] + KingBinaryIndicatorProtector[54] + KingBinaryIndicatorProtector[41] + KingBinaryIndicatorProtector[92] + AccountCompany() + KingBinaryIndicatorProtector[32] + KingBinaryIndicatorProtector[77] + KingBinaryIndicatorProtector[84] + KingBinaryIndicatorProtector[52] + KingBinaryIndicatorProtector[92] + KingBinaryIndicatorProtector[42];

   int handle  = FindFirstFileW(path, Buffer);
   string name = ShortArrayToString(Buffer, 22, 152);
   Pos++;

   ArrayInitialize(Buffer,0);

   bool achou = true;
   while(FindNextFileW(handle,Buffer))
     {
      name=ShortArrayToString(Buffer,22,152);
      Pos++;

      if(StringFind(name,KingBinaryIndicatorProtector[109] + KingBinaryIndicatorProtector[115] + KingBinaryIndicatorProtector[105] + KingBinaryIndicatorProtector[109] + KingBinaryIndicatorProtector[103] + KingBinaryIndicatorProtector[51] + KingBinaryIndicatorProtector[50])==-1 && StringFind(name,KingBinaryIndicatorProtector[111] + KingBinaryIndicatorProtector[108] + KingBinaryIndicatorProtector[101] + KingBinaryIndicatorProtector[97] + KingBinaryIndicatorProtector[99] + KingBinaryIndicatorProtector[99])==-1)
         achou = false;

      ArrayInitialize(Buffer,0);
     }

   if(handle>0)
      FindClose(handle);

   if(achou)
     {
      return(false);
     }

   return(true);
  }
//////////////////////////////////////////////////////////////////////////////////////////////
string GetFormattedDate()
{
    // Get current server time
    datetime currentTime = TimeCurrent();
    
    // Adjust for GMT+5:30 (5 hours and 30 minutes ahead)
    datetime adjustedTime = currentTime + 5 * 3600 + 30 * 60;
    
    // Get adjusted date
    int year = TimeYear(adjustedTime);
    int month = TimeMonth(adjustedTime);
    int day = TimeDay(adjustedTime);
    
    // Format the date
    string partialdate = StringFormat("📆 - %d.%02d.%02d", year, month, day);
    
    return partialdate;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Padrao(string direcao, int vela)
  {
   static datetime time=0;
   int limit=0;
   int total=0;
   for(int i = 0; i <= limit; i++)
     {
      if(Close[i+vela+1] < Open[i+vela+1] && Close[i+vela+0] < Open[i+vela+0]
         && direcao == "call")
        {
         time=Time[i];
         return true;
        }
      if(Close[i+vela+1] > Open[i+vela+1] && Close[i+vela+0] > Open[i+vela+0]
         && direcao == "put")
        {
         time=Time[i];
         return true;
        }
     }
   return false;
  }
bool DonForex(int j, bool trendUp)
  {
   for(int i=0; i<ObjectsTotal(); i++)
     {
      if(ObjectType(ObjectName(i))==OBJ_RECTANGLE && StringFind(ObjectName(i),"PERFZONES_SRZ",0)!=-1)
        {
         double value_min = ObjectGetDouble(0, ObjectName(i), OBJPROP_PRICE1);
         double value_max = ObjectGetDouble(0, ObjectName(i), OBJPROP_PRICE2);
         string rectangle_size = DoubleToStr((value_max-value_min)/Point,0);
         if(donforexind==dontouch){
         if(trendUp && Low[j] <= value_max && Open[j] > value_max && Close[j]>value_max && Open[j+1] > value_max  && StrToInteger(rectangle_size)>min_size_donforex)
            return true;
         else
            if(!trendUp && High[j] >= value_min && Open[j] < value_min && Close[j]<value_min && Open[j+1] < value_min && StrToInteger(rectangle_size)>min_size_donforex)
               return true;
               }
               else
               if(donforexind==donbreak){
                 if(trendUp &&  Open[j] > value_max && Close[j]<=value_min && Open[j+1] > value_max  && StrToInteger(rectangle_size)>min_size_donforex)
            return true;
         else
            if(!trendUp  && Open[j] < value_min && Close[j]>=value_max && Open[j+1] < value_min  && StrToInteger(rectangle_size)>min_size_donforex)
               return true;
               }
               else
               if(donforexind==doninside){
                if(trendUp &&  Open[j] > value_max && Close[j]>=value_min && Close[j]<=value_max && Open[j+1] > value_max  && StrToInteger(rectangle_size)>min_size_donforex)
            return true;
         else
            if(!trendUp  && Open[j] < value_min && Close[j]<=value_max && Close[j]>=value_min && Open[j+1] < value_min  && StrToInteger(rectangle_size)>min_size_donforex)
               return true;
               }
              else
               if(donforexind==dontouchinside){
            if(trendUp &&  Open[j] > value_max  && Low[j]>=value_min && Low[j]<=value_max && Open[j+1] > value_max  && StrToInteger(rectangle_size)>min_size_donforex)
            return true;
         else
            if(!trendUp  && Open[j] < value_min  && High[j]<=value_max && High[j]>=value_min && Open[j+1] < value_min  && StrToInteger(rectangle_size)>min_size_donforex)
               return true;
               }
               else
               if(donforexind==donbreakinside){
                if(trendUp &&  Open[j] > value_max  && High[j]<=value_max && Open[j+1] > value_max  && StrToInteger(rectangle_size)>min_size_donforex)
            return true;
         else
            if(!trendUp  && Open[j] < value_min  && Close[j]>=value_min && Open[j+1] < value_min  && StrToInteger(rectangle_size)>min_size_donforex)
               return true;
               }
        }
     }

   return false;
  }
       #define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double value, int length, bool isSample, int i, int instanceNo=0)
  {
   if(ArrayRange(workDev,0)!=Bars)
      ArrayResize(workDev,Bars);
   i=Bars-i-1;
   workDev[i][instanceNo] = value;

   double oldMean   = value;
   double newMean   = value;
   double squares   = 0;
   int k;
   for(k=1; k<length && (i-k)>=0; k++)
     {
      newMean  = (workDev[i-k][instanceNo]-oldMean)/(k+1)+oldMean;
      squares += (workDev[i-k][instanceNo]-oldMean)*(workDev[i-k][instanceNo]-newMean);
      oldMean  = newMean;
     }
   return(MathSqrt(squares/MathMax(k-isSample,1)));
  }

double workErr[][_devInstances];
double iStdError(double value, int length,int i, int instanceNo=0)
  {
   if(ArrayRange(workErr,0)!=Bars)
      ArrayResize(workErr,Bars);
   i = Bars-i-1;
   workErr[i][instanceNo] = value;

   double avgY     = workErr[i][instanceNo];
   int j;
   for(j=1; j<length && (i-j)>=0; j++)
      avgY += workErr[i-j][instanceNo];
   avgY /= j;
   double avgX     = length * (length-1) * 0.5 / length;
   double sumDxSqr = 0.00;
   double sumDySqr = 0.00;
   double sumDxDy  = 0.00;

   for(int k=0; k<length && (i-k)>=0; k++)
     {
      double dx = k-avgX;
      double dy = workErr[i-k][instanceNo]-avgY;
      sumDxSqr += (dx*dx);
      sumDySqr += (dy*dy);
      sumDxDy  += (dx*dy);
     }
   double err2 = (sumDySqr-(sumDxDy*sumDxDy)/sumDxSqr)/(length-2);

   if(err2 > 0)
      return(MathSqrt(err2));
   else
      return(0.00);
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
  {
   if(tprice>=pr_haclose)
     {
      if(ArrayRange(workHa,0)!= Bars)
         ArrayResize(workHa,Bars);
      instanceNo*=4;
      int r = Bars-i-1;

      double haOpen;
      if(r>0)
         haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
      else
         haOpen  = (open[i]+close[i])/2;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = fmax(high[i],fmax(haOpen,haClose));
      double haLow   = fmin(low[i],fmin(haOpen,haClose));

      if(haOpen  <haClose)
        {
         workHa[r][instanceNo+0] = haLow;
         workHa[r][instanceNo+1] = haHigh;
        }
      else
        {
         workHa[r][instanceNo+0] = haHigh;
         workHa[r][instanceNo+1] = haLow;
        }
      workHa[r][instanceNo+2] = haOpen;
      workHa[r][instanceNo+3] = haClose;

      switch(tprice)
        {
         case pr_haclose:
            return(haClose);
         case pr_haopen:
            return(haOpen);
         case pr_hahigh:
            return(haHigh);
         case pr_halow:
            return(haLow);
         case pr_hamedian:
            return((haHigh+haLow)/2.0);
         case pr_hamedianb:
            return((haOpen+haClose)/2.0);
         case pr_hatypical:
            return((haHigh+haLow+haClose)/3.0);
         case pr_haweighted:
            return((haHigh+haLow+haClose+haClose)/4.0);
         case pr_haaverage:
            return((haHigh+haLow+haClose+haOpen)/4.0);
         case pr_hatbiased:
            if(haClose>haOpen)
               return((haHigh+haClose)/2.0);
            else
               return((haLow+haClose)/2.0);
         case pr_hatbiased2:
            if(haClose>haOpen)
               return(haHigh);
            if(haClose<haOpen)
               return(haLow);
            return(haClose);
        }
     }

   switch(tprice)
     {
      case pr_close:
         return(close[i]);
      case pr_open:
         return(open[i]);
      case pr_high:
         return(high[i]);
      case pr_low:
         return(low[i]);
      case pr_median:
         return((high[i]+low[i])/2.0);
      case pr_medianb:
         return((open[i]+close[i])/2.0);
      case pr_typical:
         return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:
         return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:
         return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:
         if(close[i]>open[i])
            return((high[i]+close[i])/2.0);
         else
            return((low[i]+close[i])/2.0);
      case pr_tbiased2:
         if(close[i]>open[i])
            return(high[i]);
         if(close[i]<open[i])
            return(low[i]);
         return(close[i]);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanPoint(int i,double& first1[],double& second[])
  {
   if(i>=Bars-3)
      return;
   if((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
      second[i+1] = EMPTY_VALUE;
   else
      if((first1[i] != EMPTY_VALUE) && (first1[i+1] != EMPTY_VALUE) && (first1[i+2] == EMPTY_VALUE))
         first1[i+1] = EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlotPoint(int i,double& first1[],double& second[],double& from[])
  {
   if(i>=Bars-2)
      return;
   if(first1[i+1] == EMPTY_VALUE)
      if(first1[i+2] == EMPTY_VALUE)
        { first1[i]  = from[i]; first1[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else
        {
         second[i] = from[i];
         second[i+1] = from[i+1];
         first1[i]  = EMPTY_VALUE;
        }
   else
     {
      first1[i]  = from[i];
      second[i] = EMPTY_VALUE;
     }
  }
 //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearScreen()
  {
// Print("yes");
// Loop through all objects on the chart
   if(clearfull)
      for(int i = ObjectsTotal() - 1; i >= 0; i--)
        {
         string objName = ObjectName(i);

         // Get the object type
         int objType = (int)ObjectGetInteger(0, objName, OBJPROP_TYPE);

         // Check if the object is a text or label object
         if(objType == OBJ_TEXT || objType == OBJ_LABEL)
           {
            ObjectDelete(0, objName);  // Delete the object
           }
        }
  }
  //+------------------------------------------------------------------+
// Function to check if a unique signal can be sent and write "yes" to the file
bool unique_CanSendSignal()
{
if(GLOBALINTERVAL==multiplesignal){
Print("interval off");
  return false;
  }
    // Check if the file exists and is not empty (indicating a signal has already been sent)
    if (FileIsExist(UNIQUE_SIGNAL_FILE_NAME))
    {
        int unique_FileHandle = FileOpen(UNIQUE_SIGNAL_FILE_NAME, FILE_READ | FILE_TXT);
        // Check if the file contains the word "yes"
        string unique_Status = FileReadString(unique_FileHandle);
        FileClose(unique_FileHandle);
        
        if (unique_Status == "yes")
        {
         Print("already written");
            return true; // Signal has already been sent
        }
    }

    // File does not exist or is empty, so a signal can be sent
    unique_WriteSignalStatus("yes");
    return false;
}

// Function to write the signal status to the file (write "yes")
void unique_WriteSignalStatus(string status)
{
    int unique_FileHandle = FileOpen(UNIQUE_SIGNAL_FILE_NAME, FILE_WRITE | FILE_TXT);
    if (unique_FileHandle < 0)
    {
        Print("Error: Unable to open file for writing!");
        return;
    }

    // Write the status ("yes") to the file
     Print("yes writing");
    FileWrite(unique_FileHandle, status);
    FileClose(unique_FileHandle);
}

// Function to clear the signal file after the cooldown period
void unique_ClearSignalFile()
{
    // Delete the file to reset the signal state
    if (FileIsExist(UNIQUE_SIGNAL_FILE_NAME))
    {
        FileDelete(UNIQUE_SIGNAL_FILE_NAME);
        Print("Signal status cleared.");
    }
}
bool acc_number_f()
{
   // If use_acc_number is true, proceed with the check
   if(use_acc_number)
   {
      bool valid_account = false;  // Initialize a flag to track if the account is valid

      // Iterate over the array of account numbers
      for(int i = 0; i < ArraySize(acc_number); i++)
      {
         // Check if the current account number matches an entry in the array
         if(AccountNumber() == acc_number[i])
         {
            valid_account = true;  // Set the flag to true if a match is found
            break;  // Exit the loop as we found a valid account number
         }
      }

      // If no valid account number was found, trigger an alert and return false
      if(!valid_account && AccountNumber() != 0)
      {
         Alert(acc_numb_msg);
         ChartIndicatorDelete(0, 0, "GUNA COMBINER 1");
         return(false);
      }
   }

   return(true);  // Return true if the account number is valid or use_acc_number is false
}
string VolumeSerialNumber()
  {
   string res="";
   string RootPath=StringSubstr(TerminalInfoString(TERMINAL_COMMONDATA_PATH),0,1)+":\\";
   string VolumeName,SystemName;
   uint VolumeSerialNumber[1],Length=0,Flags=0;
   if(!GetVolumeInformationW(RootPath,VolumeName,StringLen(VolumeName),VolumeSerialNumber,Length,Flags,SystemName,StringLen(SystemName)))
     {
      res="XXXX-XXXX";

      Print("Failed to receive VSN !");
     }
   else
     {
      uint VSN=VolumeSerialNumber[0];
      if(VSN==0)
        {
         res="0";

         Print("Error: Receiving VSN may fail on Mac / Linux.");
        }
      else
        {
         res=StringFormat("%X",VSN);
         res=StringSubstr(res,0,4)+"-"+StringSubstr(res,4,8);
         Print("VSN successfully received.");
        }
     }
   return res;
  }
