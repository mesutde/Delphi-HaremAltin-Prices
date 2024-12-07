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
    // REST nesnelerini olu�turma
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

    // �stek g�nderme
    RestRequest.Execute;
    ResponseContent := RestResponse.Content;

    // JSON'u ayr��t�rma
    JsonResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
    if JsonResponse = nil then
      raise Exception.Create('Ge�ersiz JSON yan�t�');
    Result := JsonResponse;
  except
    on E: Exception do
      raise Exception.Create('Hata olu�tu: ' + E.Message);
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
  HaremData := THaremData.Create; // Yeni bir THaremData �rne�i olu�tur
  try
    // "data" d���m�ne eri�im
    DataObject := JsonResponse.GetValue('data') as TJSONObject;
    if DataObject = nil then
      raise Exception.Create('"data" d���m� bulunamad�');

    // "ALTIN" d���m�ne eri�im ve de�erleri al
    AltinObject := DataObject.GetValue('KULCEALTIN') as TJSONObject;
    if AltinObject <> nil then
    begin
      HaremData.GramAltinAlis := AltinObject.GetValue('alis').Value;
      HaremData.GramAltinSatis := AltinObject.GetValue('satis').Value;
      HaremData.SonGuncellemeTarihi := AltinObject.GetValue('tarih').Value;
    end;

    // "ONS" d���m�ne eri�im ve de�erleri al
    OnsObject := DataObject.GetValue('ONS') as TJSONObject;
    if OnsObject <> nil then
    begin
      HaremData.OnsAlis := OnsObject.GetValue('alis').Value;
      HaremData.OnsSatis := OnsObject.GetValue('satis').Value;
    end;

    // "USDTRY" d���m�ne eri�im ve de�erleri al
    UsdTryObject := DataObject.GetValue('USDTRY') as TJSONObject;
    if UsdTryObject <> nil then
    begin
      HaremData.DolarTRYAlis := UsdTryObject.GetValue('alis').Value;
      HaremData.DolarTRYSatis := UsdTryObject.GetValue('satis').Value;
      HaremData.SonGuncellemeTarihi := UsdTryObject.GetValue('tarih').Value;
    end;

    // "EURTRY" d���m�ne eri�im ve de�erleri al
    EurTryObject := DataObject.GetValue('EURTRY') as TJSONObject;
    if EurTryObject <> nil then
    begin
      HaremData.EurTryAlis := EurTryObject.GetValue('alis').Value;
      HaremData.EurTrySatis := EurTryObject.GetValue('satis').Value;
    end;

    // "CEYREK_YENI" d���m�ne eri�im ve de�erleri al
    CeyrekYeniObject := DataObject.GetValue('CEYREK_YENI') as TJSONObject;
    if CeyrekYeniObject <> nil then
    begin
      HaremData.CeyrekYeniAlis := CeyrekYeniObject.GetValue('alis').Value;
      HaremData.CeyrekYeniSatis := CeyrekYeniObject.GetValue('satis').Value;
    end;

    // "CEYREK_ESKI" d���m�ne eri�im ve de�erleri al
    CeyrekEskiObject := DataObject.GetValue('CEYREK_ESKI') as TJSONObject;
    if CeyrekEskiObject <> nil then
    begin
      HaremData.CeyrekEskiAlis := CeyrekEskiObject.GetValue('alis').Value;
      HaremData.CeyrekEskiSatis := CeyrekEskiObject.GetValue('satis').Value;
    end;

    // "GUMUSTRY" d���m�ne eri�im ve de�erleri al
    GumultryObject := DataObject.GetValue('GUMUSTRY') as TJSONObject;
    if GumultryObject <> nil then
    begin
      HaremData.GumusTryAlis := GumultryObject.GetValue('alis').Value;
      HaremData.GumusTrySatis := GumultryObject.GetValue('satis').Value;
    end;

    // "GUMUSUSD" d���m�ne eri�im ve de�erleri al
    GumusUsdObject := DataObject.GetValue('GUMUSUSD') as TJSONObject;
    if GumusUsdObject <> nil then
    begin
      HaremData.GumusUsdAlis := GumusUsdObject.GetValue('alis').Value;
      HaremData.GumusUsdSatis := GumusUsdObject.GetValue('satis').Value;
    end;

    // "GBPTRY" d���m�ne eri�im ve de�erleri al
    GBPTRYObject := DataObject.GetValue('GBPTRY') as TJSONObject;
    if GBPTRYObject <> nil then
    begin
      HaremData.GBPTRYAlis := GBPTRYObject.GetValue('alis').Value;
      HaremData.GBPTRYSatis := GBPTRYObject.GetValue('satis').Value;
    end;

    // "GBPUSD" d���m�ne eri�im ve de�erleri al
    GBPUSDObject := DataObject.GetValue('GBPUSD') as TJSONObject;
    if GBPUSDObject <> nil then
    begin
      HaremData.GBPUSDAlis := GBPUSDObject.GetValue('alis').Value;
      HaremData.GBPUSDSatis := GBPUSDObject.GetValue('satis').Value;
    end;

    // Sonu� olarak s�n�f� d�nd�r
    Result := HaremData;
  except
    on E: Exception do
    begin
      HaremData.Free; // Hata durumunda bellek s�z�nt�s�n� �nle
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
    // JSON yan�t�n� al
    JsonResponse := GetAllHaremExchange;
    try
      mmHarem.Lines.Clear;
      // Yan�t� i�le ve sonu�lar� s�n�fa ata
      HaremData := ProcessResponse(JsonResponse);
      lblGuncellemeTarihi.Caption := 'G�ncelleme Tarihi : ' +
        HaremData.SonGuncellemeTarihi;

      mmHarem.Lines.Add('Alt�n ONS Al�� Fiyat�: ' + HaremData.OnsAlis +
        ' USD - Alt�n ONS Sat�� Fiyat� ' + HaremData.OnsSatis + ' USD');
      mmHarem.Lines.Add('Gram Alt�n Al�� Fiyat�: ' + HaremData.GramAltinAlis +
        ' TL - Gram Alt�n Sat�� Fiyat�: ' + HaremData.GramAltinSatis + ' TL');
      mmHarem.Lines.Add('Gram G�m�� Al�� Fiyat�: ' + HaremData.GumusUsdAlis +
        ' USD - Gram G�m�� Sat�� Fiyat�: ' + HaremData.GumusUsdSatis + ' USD');
      mmHarem.Lines.Add('Gram G�m�� Al�� Fiyat�: ' + HaremData.GumusTryAlis +
        ' TL - Gram G�m�� Sat�� Fiyat�: ' + HaremData.GumusTrySatis + ' TL');
      mmHarem.Lines.Add('----');
      mmHarem.Lines.Add('Dolar/TL Al�� Fiyat�: ' + HaremData.DolarTRYAlis +
        ' TL - Dolar/TL Sat�� Fiyat�: ' + HaremData.DolarTRYSatis + ' TL');
      mmHarem.Lines.Add('Euro/TL Al�� Fiyat�: ' + HaremData.EurTryAlis +
        ' TL - Euro/TL Sat�� Fiyat�: ' + HaremData.EurTrySatis + ' TL');
      mmHarem.Lines.Add('Sterlin/TL Al�� Fiyat�: ' + HaremData.GBPTRYAlis +
        ' TL - Sterlin/TL Sat�� Fiyat�: ' + HaremData.GBPTRYSatis + ' TL');
      mmHarem.Lines.Add('Sterlin/USD Al�� Fiyat�: ' + HaremData.GBPUSDAlis +
        ' TL - Sterlin/USD Sat�� Fiyat�: ' + HaremData.GBPUSDSatis + ' TL');

    finally
      HaremData.Free; // Belle�i serbest b�rak
    end;
  finally
    JsonResponse.Free; // JSON nesnesini serbest b�rak
  end;

end;

end.
