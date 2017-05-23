use strict;
use warnings;
use Test::More tests => 1;
use WWW::Correios::SRO;

my $content = q{<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><X-OPNET-Transaction-Trace:X-OPNET-Transaction-Trace xmlns:X-OPNET-Transaction-Trace="http://opnet.com">pid=41517,requestid=48242f7f60b2af57aac8f547938ecb01a0d5acf4ea051273</X-OPNET-Transaction-Trace:X-OPNET-Transaction-Trace></soapenv:Header><soapenv:Body><ns2:buscaEventosResponse xmlns:ns2="http://resource.webservice.correios.com.br/"><return><versao>2.0</versao><qtd>1</qtd><objeto><numero>SW473852549BR</numero><sigla>SW</sigla><nome>e-SEDEX</nome><categoria>E-SEDEX</categoria><evento><tipo>DO</tipo><status>01</status><data>20/05/2017</data><hora>06:45</hora><descricao>Objeto encaminhado </descricao><local>CTE VILA MARIA</local><codigo>02170975</codigo><cidade>Sao Paulo</cidade><uf>SP</uf><destino><local>CDD TUCURUVI</local><codigo>02307970</codigo><cidade>Sao Paulo</cidade><bairro>Tucuruvi</bairro><uf>SP</uf></destino></evento><evento><tipo>DO</tipo><status>01</status><data>19/05/2017</data><hora>22:19</hora><descricao>Objeto encaminhado </descricao><local>CTE BELO HORIZONTE</local><codigo>31276970</codigo><cidade>BELO HORIZONTE</cidade><uf>MG</uf><destino><local>CTE VILA MARIA</local><codigo>02170975</codigo><cidade>Sao Paulo</cidade><bairro>Parque Novo Mundo</bairro><uf>SP</uf></destino></evento><evento><tipo>DO</tipo><status>01</status><data>19/05/2017</data><hora>16:47</hora><descricao>Objeto encaminhado </descricao><local>AGF BERNARDO MONTEIRO</local><codigo>30140973</codigo><cidade>Belo Horizonte</cidade><uf>MG</uf><destino><local>CTE BELO HORIZONTE</local><codigo>31276970</codigo><cidade>BELO HORIZONTE</cidade><bairro>Universitário</bairro><uf>MG</uf></destino></evento><evento><tipo>PO</tipo><status>01</status><data>19/05/2017</data><hora>15:57</hora><descricao>Objeto postado</descricao><local>AGF BERNARDO MONTEIRO</local><codigo>30140973</codigo><cidade>Belo Horizonte</cidade><uf>MG</uf></evento></objeto></return></ns2:buscaEventosResponse></soapenv:Body></soapenv:Envelope>};

my $parsed = WWW::Correios::SRO::_parse_response($content);
is_deeply(
    $parsed,
    [
      {
        'status'    => '01',
        'cidade'    => 'Sao Paulo',
        'hora'      => '06:45',
        'uf'        => 'SP',
        'descricao' => 'Objeto encaminhado',
        'tipo'      => 'DO',
        'destino'   => {
          'cidade' => 'Sao Paulo',
          'codigo' => '02307970',
          'uf'     => 'SP',
          'local'  => 'CDD TUCURUVI',
          'bairro' => 'Tucuruvi'
        },
        'codigo' => '02170975',
        'data'   => '20/05/2017',
        'local'  => 'CTE VILA MARIA'
      },
      {
        'destino' => {
          'bairro' => 'Parque Novo Mundo',
          'cidade' => 'Sao Paulo',
          'codigo' => '02170975',
          'local'  => 'CTE VILA MARIA',
          'uf'     => 'SP'
        },
        'codigo'    => '31276970',
        'local'     => 'CTE BELO HORIZONTE',
        'data'      => '19/05/2017',
        'hora'      => '22:19',
        'cidade'    => 'BELO HORIZONTE',
        'uf'        => 'MG',
        'descricao' => 'Objeto encaminhado',
        'tipo'      => 'DO',
        'status'    => '01'
      },
      {
        'local'   => 'AGF BERNARDO MONTEIRO',
        'data'    => '19/05/2017',
        'codigo'  => '30140973',
        'destino' => {
          'bairro' => 'Universitário',
          'local'  => 'CTE BELO HORIZONTE',
          'uf'     => 'MG',
          'cidade' => 'BELO HORIZONTE',
          'codigo' => '31276970'
        },
        'status'    => '01',
        'uf'        => 'MG',
        'descricao' => 'Objeto encaminhado',
        'tipo'      => 'DO',
        'hora'      => '16:47',
        'cidade'    => 'Belo Horizonte'
      },
      {
        'status'    => '01',
        'descricao' => 'Objeto postado',
        'uf'        => 'MG',
        'tipo'      => 'PO',
        'cidade'    => 'Belo Horizonte',
        'hora'      => '15:57',
        'local'     => 'AGF BERNARDO MONTEIRO',
        'data'      => '19/05/2017',
        'codigo'    => '30140973'
      }
    ],
    'proper data parsing'
);
