unit HaremDataUnit;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TCurrencyData = class
  private
    FAlis: string;
    FSatis: string;
    FTarih: string;
  public
    property Alis: string read FAlis write FAlis;
    property Satis: string read FSatis write FSatis;
    property Tarih: string read FTarih write FTarih;
  end;

type
  THaremData = class
  private
    FGramAltinAlis: string;
    FGramAltýnSatis: string;
    FUsdTryAlis: string;
    FUsdTrySatis: string;
    FOnsAlis: string;
    FOnsSatis: string;
    FEurTryAlis: string;
    FEurTrySatis: string;
    FCeyrekYeniAlis: string;
    FCeyrekYeniSatis: string;
    FCeyrekEskiAlis: string;
    FCeyrekEskiSatis: string;
    FGumusTryAlis: string;
    FGumusTrySatis: string;
    FGumusUsdAlis: string;
    FGumusUsdSatis: string;
    FGBPTRYAlis: string;
    FGBPTRYSatis: string;
    FGBPUSDAlis: string;
    FGBPUSDSatis: string;
    FGuncelTarih: string;
    FCurrencyData: TObjectDictionary<string, TCurrencyData>;
  public

    constructor Create;
    destructor Destroy; override;

    procedure AddCurrency(const Code, Alis, Satis, Tarih: string);
    function GetCurrency(const Code: string): TCurrencyData;

    // Güncelleme Tarihi
    property SonGuncellemeTarihi: string read FGuncelTarih write FGuncelTarih;

    // Gram Altýn Alýþ/Satýþ
    property GramAltinAlis: string read FGramAltinAlis write FGramAltinAlis;
    property GramAltinSatis: string read FGramAltýnSatis write FGramAltýnSatis;

    // USD/TRY Alýþ/Satýþ
    property DolarTRYAlis: string read FUsdTryAlis write FUsdTryAlis;
    property DolarTRYSatis: string read FUsdTrySatis write FUsdTrySatis;

    // ONS Alýþ/Satýþ
    property OnsAlis: string read FOnsAlis write FOnsAlis;
    property OnsSatis: string read FOnsSatis write FOnsSatis;

    // EUR/TRY Alýþ/Satýþ
    property EurTryAlis: string read FEurTryAlis write FEurTryAlis;
    property EurTrySatis: string read FEurTrySatis write FEurTrySatis;

    // Çeyrek Yeni Alýþ/Satýþ
    property CeyrekYeniAlis: string read FCeyrekYeniAlis write FCeyrekYeniAlis;
    property CeyrekYeniSatis: string read FCeyrekYeniSatis
      write FCeyrekYeniSatis;

    // Çeyrek Eski Alýþ/Satýþ
    property CeyrekEskiAlis: string read FCeyrekEskiAlis write FCeyrekEskiAlis;
    property CeyrekEskiSatis: string read FCeyrekEskiSatis
      write FCeyrekEskiSatis;

    // Gümüþ TRY Alýþ/Satýþ
    property GumusTryAlis: string read FGumusTryAlis write FGumusTryAlis;
    property GumusTrySatis: string read FGumusTrySatis write FGumusTrySatis;

    // Gümüþ USD Alýþ/Satýþ
    property GumusUsdAlis: string read FGumusUsdAlis write FGumusUsdAlis;
    property GumusUsdSatis: string read FGumusUsdSatis write FGumusUsdSatis;

    // GBP/TRY Alýþ/Satýþ
    property GBPTRYAlis: string read FGBPTRYAlis write FGBPTRYAlis;
    property GBPTRYSatis: string read FGBPTRYSatis write FGBPTRYSatis;

    // GBP/USD Alýþ/Satýþ
    property GBPUSDAlis: string read FGBPUSDAlis write FGBPUSDAlis;
    property GBPUSDSatis: string read FGBPUSDSatis write FGBPUSDSatis;

  end;

implementation

constructor THaremData.Create;
begin
  FCurrencyData := TObjectDictionary<string, TCurrencyData>.Create
    ([doOwnsValues]);
end;

destructor THaremData.Destroy;
begin
  FCurrencyData.Free;
  inherited;
end;

procedure THaremData.AddCurrency(const Code, Alis, Satis, Tarih: string);
var
  Currency: TCurrencyData;
begin
  Currency := TCurrencyData.Create;
  Currency.Alis := Alis;
  Currency.Satis := Satis;
  Currency.Tarih := Tarih;
  FCurrencyData.Add(Code, Currency);
end;

function THaremData.GetCurrency(const Code: string): TCurrencyData;
begin
  if FCurrencyData.ContainsKey(Code) then
    Result := FCurrencyData[Code]
  else
    Result := nil;
end;

end.
