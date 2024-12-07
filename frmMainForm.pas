unit frmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.JSON, REST.Client, REST.Types,
  HaremDataUnit,
  Vcl.StdCtrls, Vcl.Buttons;

type
  TForm1 = class(TForm)
    mmHarem: TMemo;
    lblGuncellemeTarihi: TLabel;
    btnHarem: TBitBtn;
    procedure btnHaremClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function GetAllHaremExchange: TJSONObject;
var
  RestClient: TRESTClient;
  RestRequest: TRESTRequest;
  RestResponse: TRESTResponse;
  ResponseContent: string;
  JsonResponse: TJSONObject;
begin
  try
    // REST nesnelerini oluþturma
    RestClient := TRESTClient.Create('https://www.haremaltin.com');
    RestRequest := TRESTRequest.Create(nil);
    RestResponse := TRESTResponse.Create(nil);

    // RestClient.Timeout := -1;
    RestRequest.Client := RestClient;
    RestRequest.Response := RestResponse;
    RestRequest.Method := TRESTRequestMethod.rmGET;
    RestRequest.Resource := '/dashboard/ajax/doviz';

    // Header ekleme
    RestRequest.AddParameter('content-type',
      'application/x-www-form-urlencoded; charset=UTF-8', pkHTTPHEADER,
      [poDoNotEncode]);
    RestRequest.AddParameter('x-requested-with', 'XMLHttpRequest', pkHTTPHEADER,
      [poDoNotEncode]);
    RestRequest.AddParameter('Cookie',
      'PHPSESSID=j8lgfpgqf0n589u0ohr3vf8nqk; SERVERID=004', pkHTTPHEADER,
      [poDoNotEncode]);

    // Ýstek gönderme
    RestRequest.Execute;
    ResponseContent := RestResponse.Content;

    // JSON'u ayrýþtýrma
    JsonResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
    if JsonResponse = nil then
      raise Exception.Create('Geçersiz JSON yanýtý');
    Result := JsonResponse;
  except
    on E: Exception do
      raise Exception.Create('Hata oluþtu: ' + E.Message);
  end;
end;

function ProcessResponse(JsonResponse: TJSONObject): THaremData;
var
  DataObject, AltinObject, OnsObject, EurTryObject, CeyrekYeniObject,
    CeyrekEskiObject, GumultryObject, GumusUsdObject, UsdTryObject,
    GBPTRYObject, GBPUSDObject: TJSONObject;
  HaremData: THaremData;
  CurrencyCode, Alis, Satis, Tarih: string;
begin
  HaremData := THaremData.Create; // Yeni bir THaremData örneði oluþtur
  try
    // "data" düðümüne eriþim
    DataObject := JsonResponse.GetValue('data') as TJSONObject;
    if DataObject = nil then
      raise Exception.Create('"data" düðümü bulunamadý');

    // "ALTIN" düðümüne eriþim ve deðerleri al
    AltinObject := DataObject.GetValue('KULCEALTIN') as TJSONObject;
    if AltinObject <> nil then
    begin
      HaremData.GramAltinAlis := AltinObject.GetValue('alis').Value;
      HaremData.GramAltinSatis := AltinObject.GetValue('satis').Value;
      HaremData.SonGuncellemeTarihi := AltinObject.GetValue('tarih').Value;
    end;

    // "ONS" düðümüne eriþim ve deðerleri al
    OnsObject := DataObject.GetValue('ONS') as TJSONObject;
    if OnsObject <> nil then
    begin
      HaremData.OnsAlis := OnsObject.GetValue('alis').Value;
      HaremData.OnsSatis := OnsObject.GetValue('satis').Value;
    end;

    // "USDTRY" düðümüne eriþim ve deðerleri al
    UsdTryObject := DataObject.GetValue('USDTRY') as TJSONObject;
    if UsdTryObject <> nil then
    begin
      HaremData.DolarTRYAlis := UsdTryObject.GetValue('alis').Value;
      HaremData.DolarTRYSatis := UsdTryObject.GetValue('satis').Value;
      HaremData.SonGuncellemeTarihi := UsdTryObject.GetValue('tarih').Value;
    end;

    // "EURTRY" düðümüne eriþim ve deðerleri al
    EurTryObject := DataObject.GetValue('EURTRY') as TJSONObject;
    if EurTryObject <> nil then
    begin
      HaremData.EurTryAlis := EurTryObject.GetValue('alis').Value;
      HaremData.EurTrySatis := EurTryObject.GetValue('satis').Value;
    end;

    // "CEYREK_YENI" düðümüne eriþim ve deðerleri al
    CeyrekYeniObject := DataObject.GetValue('CEYREK_YENI') as TJSONObject;
    if CeyrekYeniObject <> nil then
    begin
      HaremData.CeyrekYeniAlis := CeyrekYeniObject.GetValue('alis').Value;
      HaremData.CeyrekYeniSatis := CeyrekYeniObject.GetValue('satis').Value;
    end;

    // "CEYREK_ESKI" düðümüne eriþim ve deðerleri al
    CeyrekEskiObject := DataObject.GetValue('CEYREK_ESKI') as TJSONObject;
    if CeyrekEskiObject <> nil then
    begin
      HaremData.CeyrekEskiAlis := CeyrekEskiObject.GetValue('alis').Value;
      HaremData.CeyrekEskiSatis := CeyrekEskiObject.GetValue('satis').Value;
    end;

    // "GUMUSTRY" düðümüne eriþim ve deðerleri al
    GumultryObject := DataObject.GetValue('GUMUSTRY') as TJSONObject;
    if GumultryObject <> nil then
    begin
      HaremData.GumusTryAlis := GumultryObject.GetValue('alis').Value;
      HaremData.GumusTrySatis := GumultryObject.GetValue('satis').Value;
    end;

    // "GUMUSUSD" düðümüne eriþim ve deðerleri al
    GumusUsdObject := DataObject.GetValue('GUMUSUSD') as TJSONObject;
    if GumusUsdObject <> nil then
    begin
      HaremData.GumusUsdAlis := GumusUsdObject.GetValue('alis').Value;
      HaremData.GumusUsdSatis := GumusUsdObject.GetValue('satis').Value;
    end;

    // "GBPTRY" düðümüne eriþim ve deðerleri al
    GBPTRYObject := DataObject.GetValue('GBPTRY') as TJSONObject;
    if GBPTRYObject <> nil then
    begin
      HaremData.GBPTRYAlis := GBPTRYObject.GetValue('alis').Value;
      HaremData.GBPTRYSatis := GBPTRYObject.GetValue('satis').Value;
    end;

    // "GBPUSD" düðümüne eriþim ve deðerleri al
    GBPUSDObject := DataObject.GetValue('GBPUSD') as TJSONObject;
    if GBPUSDObject <> nil then
    begin
      HaremData.GBPUSDAlis := GBPUSDObject.GetValue('alis').Value;
      HaremData.GBPUSDSatis := GBPUSDObject.GetValue('satis').Value;
    end;

    // Sonuç olarak sýnýfý döndür
    Result := HaremData;
  except
    on E: Exception do
    begin
      HaremData.Free; // Hata durumunda bellek sýzýntýsýný önle
      raise Exception.Create('Hata: ' + E.Message);
    end;
  end;
end;

procedure TForm1.btnHaremClick(Sender: TObject);
var
  JsonResponse: TJSONObject;
  HaremData: THaremData;
  CurrencyData: TCurrencyData;
begin
  try
    // JSON yanýtýný al
    JsonResponse := GetAllHaremExchange;
    try
      mmHarem.Lines.Clear;
      // Yanýtý iþle ve sonuçlarý sýnýfa ata
      HaremData := ProcessResponse(JsonResponse);
      lblGuncellemeTarihi.Caption := 'Güncelleme Tarihi : ' +
        HaremData.SonGuncellemeTarihi;

      mmHarem.Lines.Add('Altýn ONS Alýþ Fiyatý: ' + HaremData.OnsAlis +
        ' USD - Altýn ONS Satýþ Fiyatý ' + HaremData.OnsSatis + ' USD');
      mmHarem.Lines.Add('Gram Altýn Alýþ Fiyatý: ' + HaremData.GramAltinAlis +
        ' TL - Gram Altýn Satýþ Fiyatý: ' + HaremData.GramAltinSatis + ' TL');
      mmHarem.Lines.Add('Gram Gümüþ Alýþ Fiyatý: ' + HaremData.GumusUsdAlis +
        ' USD - Gram Gümüþ Satýþ Fiyatý: ' + HaremData.GumusUsdSatis + ' USD');
      mmHarem.Lines.Add('Gram Gümüþ Alýþ Fiyatý: ' + HaremData.GumusTryAlis +
        ' TL - Gram Gümüþ Satýþ Fiyatý: ' + HaremData.GumusTrySatis + ' TL');
      mmHarem.Lines.Add('----');
      mmHarem.Lines.Add('Dolar/TL Alýþ Fiyatý: ' + HaremData.DolarTRYAlis +
        ' TL - Dolar/TL Satýþ Fiyatý: ' + HaremData.DolarTRYSatis + ' TL');
      mmHarem.Lines.Add('Euro/TL Alýþ Fiyatý: ' + HaremData.EurTryAlis +
        ' TL - Euro/TL Satýþ Fiyatý: ' + HaremData.EurTrySatis + ' TL');
      mmHarem.Lines.Add('Sterlin/TL Alýþ Fiyatý: ' + HaremData.GBPTRYAlis +
        ' TL - Sterlin/TL Satýþ Fiyatý: ' + HaremData.GBPTRYSatis + ' TL');
      mmHarem.Lines.Add('Sterlin/USD Alýþ Fiyatý: ' + HaremData.GBPUSDAlis +
        ' TL - Sterlin/USD Satýþ Fiyatý: ' + HaremData.GBPUSDSatis + ' TL');

    finally
      HaremData.Free; // Belleði serbest býrak
    end;
  finally
    JsonResponse.Free; // JSON nesnesini serbest býrak
  end;

end;

end.
