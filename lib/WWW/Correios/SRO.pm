package WWW::Correios::SRO::Item;
use Class::XSAccessor::Array {
    constructor => 'new',
    accessors  => {
        'data'     => 0,
        'date'     => 0,
        'location' => 1,
        'local'    => 1,
        'status'   => 2,
        'extra'    => 3,
    },
};

package WWW::Correios::SRO;

use strict;
use warnings;

use LWP::UserAgent;
use HTML::TreeBuilder;

use parent 'Exporter';
our @EXPORT_OK = qw( sro sro_en sro_ok sro_sigla );

our $VERSION = '0.10';
my $AGENT = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
my $TIMEOUT = 30;

# Verificado em 22 de Maio de 2017
# http://www.correios.com.br/para-voce/precisa-de-ajuda/como-rastrear-um-objeto/siglas-utilizadas-no-rastreamento-de-objeto
#
#
# Sabemos que as seguintes siglas são usadas: DH
# Como não existem na tabela dos correios, nao se encontra na hash.
# Um código com esse prefixo funcionará ao usar a funcao sro sem
# passar o parametro verifica_prefixo. Porém, se passar este
# parametro, deve retornar undef como qualquer SRO
# cujo prefixo não está previsto na tabela dos Correios.
my %siglas = (
  AL => 'AGENTES DE LEITURA',
  AR => 'AVISO DE RECEBIMENTO',
  AS => 'ENCOMENDA PAC – AÇÃO SOCIAL',
  BE => 'REMESSA ECONÔMICA TALÃO/CARTÃO (SEM AR DIGITAL)',
  CA => 'ENCOMENDA INTERNACIONAL - COLIS',
  CB => 'ENCOMENDA INTERNACIONAL - COLIS',
  CC => 'ENCOMENDA INTERNACIONAL - COLIS',
  CD => 'ENCOMENDA INTERNACIONAL - COLIS',
  CE => 'ENCOMENDA INTERNACIONAL - COLIS',
  CF => 'ENCOMENDA INTERNACIONAL - COLIS',
  CG => 'ENCOMENDA INTERNACIONAL - COLIS',
  CH => 'ENCOMENDA INTERNACIONAL - COLIS',
  CI => 'ENCOMENDA INTERNACIONAL - COLIS',
  CJ => 'ENCOMENDA INTERNACIONAL - COLIS',
  CK => 'ENCOMENDA INTERNACIONAL - COLIS',
  CL => 'ENCOMENDA INTERNACIONAL - COLIS',
  CM => 'ENCOMENDA INTERNACIONAL - COLIS',
  CN => 'ENCOMENDA INTERNACIONAL - COLIS',
  CO => 'ENCOMENDA INTERNACIONAL - COLIS',
  CP => 'ENCOMENDA INTERNACIONAL - COLIS',
  CQ => 'ENCOMENDA INTERNACIONAL - COLIS',
  CR => 'CARTA REGISTRADA SEM VALOR DECLARADO',
  CS => 'ENCOMENDA INTERNACIONAL - COLIS',
  CT => 'ENCOMENDA INTERNACIONAL - COLIS',
  CU => 'ENCOMENDA INTERNACIONAL - COLIS',
  CV => 'ENCOMENDA INTERNACIONAL - COLIS',
  CW => 'ENCOMENDA INTERNACIONAL - COLIS',
  CX => 'ENCOMENDA INTERNACIONAL - COLIS OU SELO LACRE PARA CAIXETAS',
  CY => 'ENCOMENDA INTERNACIONAL - COLIS',
  CZ => 'ENCOMENDA INTERNACIONAL - COLIS',
  DA => 'SEDEX OU REMESSA EXPRESSA COM AR DIGITAL',
  DB => 'SEDEX OU REMESSA EXPRESSA COM AR DIGITAL (BRADESCO)',
  DC => 'REMESSA EXPRESSA CRLV/CRV/CNH e NOTIFICAÇÕES',
  DD => 'DEVOLUÇÃO DE DOCUMENTOS',
  DE => 'REMESSA EXPRESSA TALÃO/CARTÃO COM AR',
  DF => 'E-SEDEX',
  DG => 'SEDEX',
  DI => 'SEDEX OU REMESSA EXPRESSA COM AR DIGITAL (ITAU)',
  DJ => 'SEDEX',
  DK => 'PAC EXTRA GRANDE',
  DL => 'SEDEX',
  DM => 'E-SEDEX',
  DN => 'SEDEX',
  DO => 'SEDEX OU REMESSA EXPRESSA COM AR DIGITAL (ITAU)',
  DP => 'SEDEX PAGAMENTO NA ENTREGA',
  DQ => 'SEDEX OU REMESSA EXPRESSA COM AR DIGITAL (BRADESCO)',
  DR => 'REMESSA EXPRESSA COM AR DIGITAL (SANTANDER)',
  DS => 'SEDEX OU REMESSA EXPRESSA COM AR DIGITAL (SANTANDER)',
  DT => 'REMESSA ECONÔMICA COM AR DIGITAL (DETRAN)',
  DU => 'E-SEDEX',
  DV => 'SEDEX COM AR DIGITAL',
  DW => 'ENCOMENDA SEDEX (ETIQUETA LÓGICA)',
  DX => 'SEDEX 10',
  EA => 'ENCOMENDA INTERNACIONAL - EMS',
  EB => 'ENCOMENDA INTERNACIONAL - EMS',
  EC => 'PAC',
  ED => 'PACKET EXPRESS',
  EE => 'ENCOMENDA INTERNACIONAL - EMS',
  EF => 'ENCOMENDA INTERNACIONAL - EMS',
  EG => 'ENCOMENDA INTERNACIONAL - EMS',
  EH => 'ENCOMENDA INTERNACIONAL - EMS OU ENCOMENDA COM AR DIGITAL',
  EI => 'ENCOMENDA INTERNACIONAL - EMS',
  EJ => 'ENCOMENDA INTERNACIONAL - EMS',
  EK => 'ENCOMENDA INTERNACIONAL - EMS',
  EL => 'ENCOMENDA INTERNACIONAL - EMS',
  EM => 'ENCOMENDA INTERNACIONAL - SEDEX MUNDI OU EMS IMPORTAÇÃO',
  EN => 'ENCOMENDA INTERNACIONAL - EMS',
  EO => 'ENCOMENDA INTERNACIONAL - EMS',
  EP => 'ENCOMENDA INTERNACIONAL - EMS',
  EQ => 'ENCOMENDA DE SERVIÇO NÃO EXPRESSA (ECT)',
  ER => 'OBJETO REGISTRADO',
  ES => 'E-SEDEX OU EMS',
  ET => 'ENCOMENDA INTERNACIONAL - EMS',
  EU => 'ENCOMENDA INTERNACIONAL - EMS',
  EV => 'ENCOMENDA INTERNACIONAL - EMS',
  EW => 'ENCOMENDA INTERNACIONAL - EMS',
  EX => 'ENCOMENDA INTERNACIONAL - EMS',
  EY => 'ENCOMENDA INTERNACIONAL - EMS',
  EZ => 'ENCOMENDA INTERNACIONAL - EMS',
  FA => 'FAC REGISTRADO',
  FE => 'ENCOMENDA FNDE',
  FF => 'OBJETO REGISTRADO (DETRAN)',
  FH => 'FAC REGISTRADO COM AR DIGITAL',
  FM => 'FAC MONITORADO',
  FR => 'FAC REGISTRADO',
  IA => 'LOGÍSTICA INTEGRADA (AGENDADO/AVULSO)',
  IC => 'LOGÍSTICA INTEGRADA (A COBRAR)',
  ID => 'LOGÍSTICA INTEGRADA (DEVOLUCAO DE DOCUMENTO)',
  IE => 'LOGÍSTICA INTEGRADA (ESPECIAL)',
  IF => 'CPF',
  II => 'LOGÍSTICA INTEGRADA (ECT)',
  IK => 'LOGÍSTICA INTEGRADA COM COLETA SIMULTÂNEA',
  IM => 'LOGÍSTICA INTEGRADA (MEDICAMENTOS)',
  IN => 'CORRESPONDÊNCIA E EMS RECEBIDO DO EXTERIOR',
  IP => 'LOGÍSTICA INTEGRADA (PROGRAMADA)',
  IR => 'IMPRESSO REGISTRADO',
  IS => 'LOGÍSTICA INTEGRADA STANDARD (MEDICAMENTOS)',
  IT => 'REMESSA EXPRESSA MEDICAMENTOS / LOGÍSTICA INTEGRADA TERMOLÁBIL',
  IU => 'LOGÍSTICA INTEGRADA (URGENTE)',
  IX => 'EDEI EXPRESSO',
  JA => 'REMESSA ECONOMICA COM AR DIGITAL',
  JB => 'REMESSA ECONOMICA COM AR DIGITAL',
  JC => 'REMESSA ECONOMICA COM AR DIGITAL',
  JD => 'REMESSA ECONOMICA TALÃO/CARTÃO',
  JE => 'REMESSA ECONÔMICA COM AR DIGITAL',
  JF => 'REMESSA ECONÔMICA COM AR DIGITAL',
  JG => 'OBJETO REGISTRADO URGENTE/PRIORITÁRIO',
  JH => 'OBJETO REGISTRADO URGENTE/PRIORITÁRIO',
  JI => 'REMESSA ECONÔMICA TALÃO/CARTÃO',
  JJ => 'OBJETO REGISTRADO (JUSTIÇA)',
  JK => 'REMESSA ECONÔMICA TALÃO/CARTÃO',
  JL => 'OBJETO REGISTRADO',
  JM => 'MALA DIRETA POSTAL ESPECIAL',
  JN => 'OBJETO REGISTRADO ECONÔMICO',
  JO => 'OBJETO REGISTRADO URGENTE',
  JP => 'RECEITA FEDERAL',
  JQ => 'REMESSA ECONÔMICA COM AR DIGITAL',
  JR => 'OBJETO REGISTRADO URGENTE/PRIORITÁRIO',
  JS => 'OBJETO REGISTRADO',
  JT => 'OBJETO REGISTRADO URGENTE',
  JV => 'REMESSA ECONÔMICA COM AR DIGITAL',
  LA => 'SEDEX COM LOGÍSTICA REVERSA SIMULTÂNEA EM AGÊNCIA',
  LB => 'E-SEDEX COM LOGÍSTICA REVERSA SIMULTÂNEA EM AGÊNCIA',
  LC => 'OBJETO INTERNACIONAL (PRIME)',
  LE => 'LOGÍSTICA REVERSA ECONOMICA',
  LF => 'OBJETO INTERNACIONAL (PRIME)',
  LI => 'OBJETO INTERNACIONAL (PRIME)',
  LJ => 'OBJETO INTERNACIONAL (PRIME)',
  LK => 'OBJETO INTERNACIONAL (PRIME)',
  LM => 'OBJETO INTERNACIONAL (PRIME)',
  LN => 'OBJETO INTERNACIONAL (PRIME)',
  LP => 'PAC COM LOGÍSTICA REVERSA SIMULTÂNEA EM AGÊNCIA',
  LS => 'SEDEX LOGISTICA REVERSA',
  LV => 'LOGISTICA REVERSA EXPRESSA',
  LX => 'PACKET STANDARD/ECONÔMICA',
  LZ => 'OBJETO INTERNACIONAL (PRIME)',
  MA => 'SERVIÇOS ADICIONAIS DO TELEGRAMA',
  MB => 'TELEGRAMA (BALCÃO)',
  MC => 'TELEGRAMA (FONADO)',
  MD => 'SEDEX MUNDI (DOCUMENTO INTERNO)',
  ME => 'TELEGRAMA',
  MF => 'TELEGRAMA FONADO',
  MK => 'TELEGRAMA (CORPORATIVO)',
  ML => 'FECHA MALAS (RABICHO)',
  MM => 'TELEGRAMA (GRANDES CLIENTES)',
  MP => 'TELEGRAMA (PRÉ-PAGO)',
  MR => 'AR DIGITAL',
  MS => 'ENCOMENDA SAUDE',
  MT => 'TELEGRAMA (TELEMAIL)',
  MY => 'TELEGRAMA INTERNACIONAL (ENTRANTE)',
  MZ => 'TELEGRAMA (CORREIOS ONLINE)',
  NE => 'TELE SENA RESGATADA',
  NX => 'EDEI ECONÔMICO (NÃO URGENTE)',
  OA => 'ENCOMENDA SEDEX',
  OB => 'ENCOMENDA E-SEDEX',
  PA => 'PASSAPORTE',
  PB => 'PAC',
  PC => 'PAC A COBRAR',
  PD => 'PAC',
  PE => 'PAC',
  PF => 'PASSAPORTE',
  PG => 'PAC',
  PH => 'PAC',
  PI => 'PAC',
  PJ => 'PAC',
  PK => 'PAC EXTRA GRANDE',
  PL => 'PAC',
  PN => 'PAC',
  PR => 'REEMBOLSO POSTAL',
  QQ => 'OBJETO DE TESTE (SIGEP WEB)',
  RA => 'OBJETO REGISTRADO/PRIORITÁRIO',
  RB => 'CARTA REGISTRADA',
  RC => 'CARTA REGISTRADA COM VALOR DECLARADO',
  RD => 'REMESSA ECONOMICA OU OBJETO REGISTRADO (DETRAN)',
  RE => 'OBJETO REGISTRADO ECONÔMICO',
  RF => 'RECEITA FEDERAL',
  RG => 'OBJETO REGISTRADO',
  RH => 'OBJETO REGISTRADO COM AR DIGITAL',
  RI => 'OBJETO REGISTRADO INTERNACIONAL PRIORITÁRIO',
  RJ => 'OBJETO REGISTRADO',
  RK => 'OBJETO REGISTRADO',
  RL => 'OBJETO REGISTRADO',
  RM => 'OBJETO REGISTRADO URGENTE',
  RN => 'OBJETO REGISTRADO (SIGEPWEB OU AGÊNCIA)',
  RO => 'OBJETO REGISTRADO',
  RP => 'REEMBOLSO POSTAL',
  RQ => 'OBJETO REGISTRADO',
  RR => 'OBJETO REGISTRADO',
  RS => 'OBJETO REGISTRADO',
  RT => 'REMESSA ECONÔMICA TALÃO/CARTAO',
  RU => 'OBJETO REGISTRADO (ECT)',
  RV => 'REMESSA ECONÔMICA CRLV/CRV/CNH E NOTIFICAÇÕES COM AR DIGITAL',
  RW => 'OBJETO INTERNACIONAL',
  RX => 'OBJETO INTERNACIONAL',
  RY => 'REMESSA ECONÔMICA TALÃO/CARTÃO COM AR DIGITAL',
  RZ => 'OBJETO REGISTRADO',
  SA => 'SEDEX',
  SB => 'SEDEX 10',
  SC => 'SEDEX A COBRAR',
  SD => 'SEDEX OU REMESSA EXPRESSA (DETRAN)',
  SE => 'SEDEX',
  SF => 'SEDEX',
  SG => 'SEDEX',
  SH => 'SEDEX COM AR DIGITAL / SEDEX OU AR DIGITAL',
  SI => 'SEDEX',
  SJ => 'SEDEX HOJE',
  SK => 'SEDEX',
  SL => 'SEDEX',
  SM => 'SEDEX 12',
  SN => 'SEDEX',
  SO => 'SEDEX',
  SP => 'SEDEX PRÉ-FRANQUEADO',
  SQ => 'SEDEX',
  SR => 'SEDEX',
  SS => 'SEDEX',
  ST => 'REMESSA EXPRESSA TALÃO/CARTÃO',
  SU => 'ENCOMENDA DE SERVIÇO EXPRESSA (ECT)',
  SV => 'REMESSA EXPRESSA CRLV/CRV/CNH E NOTIFICAÇÕES COM AR DIGITAL',
  SW => 'E-SEDEX',
  SX => 'SEDEX 10',
  SY => 'REMESSA EXPRESSA TALÃO/CARTÃO COM AR DIGITAL',
  SZ => 'SEDEX',
  TC => 'OBJETO PARA TREINAMENTO',
  TE => 'OBJETO PARA TREINAMENTO',
  TS => 'OBJETO PARA TREINAMENTO',
  VA => 'ENCOMENDAS COM VALOR DECLARADO',
  VC => 'ENCOMENDAS',
  VD => 'ENCOMENDAS COM VALOR DECLARADO',
  VE => 'ENCOMENDAS',
  VF => 'ENCOMENDAS COM VALOR DECLARADO',
  VV => 'OBJETO INTERNACIONAL',
  XA => 'AVISO DE CHEGADA (INTERNACIONAL)',
  XM => 'SEDEX MUNDI',
  XR => 'ENCOMENDA SUR POSTAL EXPRESSO',
  XX => 'ENCOMENDA SUR POSTAL 24 HORAS',
);

# http://www.correios.com.br/para-sua-empresa/servicos-para-o-seu-contrato/guias/enderecamento/arquivos/guia_tecnico_encomendas.pdf/at_download/file
sub sro_ok {
  if ( $_[0] =~ m/^[A-Z|a-z]{2}([0-9]{8})([0-9])BR$/i ) {
    my ( $numeros, $dv ) = ($1, $2);
    my @numeros = split // => $numeros;
    my @magica  = ( 8, 6, 4, 2, 3, 5, 9, 7 );

    my $soma = 0;
    foreach ( 0 .. 7 ) {
      $soma += ( $numeros[$_] * $magica[$_] );
    }

    my $resto = $soma % 11;
    my $dv_check = $resto == 0 ? 5
                 : $resto == 1 ? 0
                 : 11 - $resto
                 ;
    return $dv == $dv_check;
  }
  else {
    return;
  }
}

sub sro_sigla {
  if ( sro_ok( @_ ) ) {
    $_[0] =~ m/^([A-Z|a-z]{2}).*$/i;
    my $prefixo = $1;
    return $siglas{$prefixo};
  } else {
    return;
  }
}

sub sro    { _sro('001', @_) }
sub sro_en { _sro('002', @_) }

sub _sro {
    my ($LANG, $code, $_url, $verifica_prefixo) = @_;
    return unless $code && sro_ok( $code );

    if ( defined $verifica_prefixo && $verifica_prefixo == 1 ) {
	my $prefixo = sro_sigla( $code );
        return unless ( defined $prefixo );
    }

    # internal use only: we override this during testing
    $_url = 'http://websro.correios.com.br/sro_bin/txect01$.Inexistente?P_LINGUA=' . $LANG . "&P_TIPO=002&P_COD_LIS=$code"
        unless defined $_url;

    my $agent = LWP::UserAgent->new(
                       agent   => $AGENT,
                       timeout => $TIMEOUT,
            );
    my $response = $agent->get($_url);

    return unless $response->is_success;

    my $html = HTML::TreeBuilder->new_from_content( $response->decoded_content );

    my $table = $html->find('table');

    return unless $table;
    return if ( $table->as_trimmed_text eq $code);

    my @items = $table->find('tr');

    shift @items; # drop the first 'tr'

    my $i = 0;
    my @result;
    foreach my $item (@items) {
        my @elements = $item->find('td');
        return unless @elements;

        # new entry
        if ( @elements == 3 ) {
            # short-circuit
            return $result[0] unless wantarray or $i == 0;

            my $item = WWW::Correios::SRO::Item->new;
            $item->date($elements[0]->as_trimmed_text);
            $item->location($elements[1]->as_trimmed_text);
            utf8::encode(my $status = $elements[2]->as_trimmed_text);
            $item->status($status);
            $result[$i++] = $item;
        }
        # extra info for the current entry
        else {
            return unless ref $result[$i - 1] and scalar @elements == 1;
            utf8::encode(my $extra = $elements[0]->as_trimmed_text);
            $result[$i - 1]->extra($extra);
        }
    }
    return wantarray ? @result : $result[0];
}

42;
__END__
=encoding utf8

=head1 NAME

WWW::Correios::SRO - Serviço de Rastreamento de Objetos (Brazilian Postal Object Tracking Service)


=head1 BILINGUAL MODULE

This module provides APIs in english and portuguese. Documentation is also shown in both languages.

Este módulo oferece APIs em inglês e português. Documentação também é mostrada em ambos os idiomas.


=head1 SYNOPSIS

API em português:

    use WWW::Correios::SRO qw( sro sro_ok );

    my $codigo = 'SS123456789BR';  # insira seu código de rastreamento aqui

    return 'SRO inválido' unless sro_ok( $codigo );

    my $prefixo = sro_sigla( $codigo ); # retorna "SEDEX FÍSICO";

    my @historico_completo = sro( $codigo );

    my $ultimo = sro( $codigo );

    $ultimo->data;    # '22/05/2010 12:10'
    $ultimo->local;   # 'CEE JACAREPAGUA - RIO DE JANEIRO/RJ'
    $ultimo->status;  # 'Destinatário ausente'
    $ultimo->extra;   # 'Será realizada uma nova tentativa de entrega'

English API:

    use WWW::Correios::SRO qw( sro_en sro_ok );

    my $code = 'SS123456789BR';  # insert tracking code here

    return 'invalid SRO' unless sro_ok( $code );

    my $prefix = sro_sigla( $code ); # returns "SEDEX FÍSICO";

    my @full_history = sro_en( $code );

    my $last = sro_en( $code );

    $last->date;       # '22/05/2010 12:10'
    $last->location;   # 'CEE JACAREPAGUA - RIO DE JANEIRO/RJ'
    $last->status;     # 'No receiver at the address'
    $last->extra;      # 'Delivery will be retried'

Note: All messages are created by the brazilian post office website. Some messages might not be translated.

Note #2: the sro_en() function is experimental, and could be removed in future versions with no prior notice. If you care, or have any comments/suggestions on how to improve this, please let me know.

=head1 DESCRIPTION

Este módulo oferece uma interface com o serviço de rastreamento de objetos dos Correios. Até a data de publicação deste módulo não há uma API pública dos Correios para isso, então este módulo consulta o site dos Correios diretamente e faz parsing dos resultados. Sim, isso significa que mudanças no layout do site dos Correios podem afetar o funcionamento deste módulo. Até os Correios lançarem o serviço via API, isso é o que temos.

This module provides an interface to the Brazilian Postal (Correios) object tracking service. Until the date of release of this module there was no public API to achieve this, so this module queries the Correios website directly and parses its results. Yup, this means any layout changes on their website could affect the correctness of this module. Until Correios releases an API for this service, that's all we can do.

=head1 EXPORTS

Este módulo não exporta nada por padrão. Você precisa explicitar 'sro' (para mensagens em português) ou 'sro_en' (para mensagens em inglês).

This module exports nothing by default. You have to explicitly ask for 'sro' (for the portuguese messages) or 'sro_en' (for the english messages).

=head2 sro

Recebe o código identificador do objeto. 

Em contexto escalar, retorna retorna um objeto WWW::Correios::SRO::Item contendo a entrada mais recente no registro dos Correios. Em contexto de lista, retorna um array de objetos WWW::Correios::SRO::Item, da entrada mais recente à mais antiga. Em caso de falha, retorna I<undef>. As mensagens do objeto retornado estarão em português.

Seu terceiro parâmetro, verifica_prefixo, determina se pesquisaremos apenas os códigos com prefixos apresentados pelos Correios ($verifica_prefixo = 1) ou não.
--

Receives the item identification code.

In scalar context, returns a WWW::Correios::SRO::Item object containing the most recent log entry in the Postal service. In list context, returns a list of WWW::Correios::SRO::Item objects, from the most recent entry to the oldest. Returns I<undef> upon failure. Messages on the returned object will be in portuguese.

Its thirds parameter, verifica_prefixo, determines if we shall search only the codes with prefixes shown by Brazilian Post Office ($erifica_prefixo = 1) or not.

=head2 sro_en

O mesmo que C<sro()>, mas com mensagens em inglês.

Same as C<sro()>, but with messages in english.


=head2 sro_ok

Retorna verdadeiro se o código de rastreamento passado é válido, caso contrário retorna falso. Essa função é chamada automaticamente pelas funções C<sro> e C<sro_en>, então você
não precisa se preocupar em chamá-la diretamente. Ela deve ser usada quando você quer apenas saber se o código é válido ou não, sem precisar fazer uma consulta HTTP ao site dos
correios. Essa função B<não> elimina espaços da string, você deve fazer sua própria higienização.

--

Returns true if the given tracking code is valid, false otherwise. This function is automatically called by the C<sro> and C<sro_en> functions, so you don't have to worry about calling it directly. It should be used when you just want to know whether the tracking code is valid or not, without the need to make an HTTP request to the postal office website. This function does B<not> trim whitespaces from the given string, you have to sanitize it by yourself.

=head2 sro_sigla

Retorna uma string com o significado do prefixo do código que foi passado. Retorna I<undef> caso a string não seja conhecida.

--

Returns a string with the meaning of the code's prefix. Returns I<undef> if we don't know the meaning.

=head1 OBJETO RETORNADO/RETURNED OBJECT

=head2 data

=head2 date (alias)

Retorna a data/hora em que os dados de entrega foram recebidos pelo sistema, exceto no I<< 'SEDEX 10' >> e no I<< 'SEDEX Hoje' >>, em que representa o horário real da entrega. Informação sobre onde encontrar o código para rastreamento estão disponíveis (em português) no link: L<< http://www.correios.com.br/servicos/rastreamento/como_loc_objeto.cfm >>

Returns the date/time in which the delivery data got into the system, except on I<< 'SEDEX 10' >> and I<< 'SEDEX Hoje' >>, where it corresponds to the actual delivery date. Information on how to find the tracking code is available in the link: L<< http://www.correios.com.br/servicos/rastreamento/como_loc_objeto.cfm >> (follow the "English version" link on that page).


=head2 local

=head2 location (alias)

Retorna local em que o evento ocorreu. A string retornada é prefixada por uma sigla, como B<ACF> (Agência de Correios Franqueada), B<CTE> (Centro de Tratamento de Encomendas), B<CTCE> (Centro de Tratamento de Cartas e Encomendas), B<CTCI> (Centro de Tratamento de Correio Internacional), B<CDD> (Centro de Distribuição Domiciliária), B<CEE> (Centro de Entrega de Encomendas).

Returns the location where the event ocurred. The returned string is prefixed by an acronym like B<ACF> (Franchised Postal Agency), B<CTE> (Center for Item Assessment), B<CTCE> (Center for Item and Mail Assessment), B<CTCI> (Center for International Postal Assessment), B<CDD> (Center for Domiciliary Distribution), B<CEE> (Center for Item Delivery).


=head2 status

Retorna a situação registrada para o evento (postado, encaminhado, destinatário ausente, etc)

Returns the registered situation for the event (no receiver at the address, etc)


=head2 extra

Contém informações adicionais a respeito do evento, ou I<undef>. Exemplo: 'Será realizada uma nova tentativa de entrega'.

Contains additional information about the event, or I<undef>. E.g.: 'Delivery will be retried'


=head1 AUTHOR

Breno G. de Oliveira, C<< <garu at cpan.org> >>

=head1 BUGS

Por favor envie bugs ou pedidos para C<bug-www-correios-sro at rt.cpan.org>, ou pela interface web em L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Correios-SRO>. Eu serei notificado, e então você será automaticamente notificado sobre qualquer progresso na questão.

Please report any bugs or feature requests to C<bug-www-correios-sro at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Correios-SRO>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 AGRADECIMENTOS/ACKNOWLEDGEMENTS

Este módulo não existiria sem o serviço gratuito de rastreamento online dos Correios. 

L<< http://www.correios.com.br/servicos/rastreamento/ >>


=head1 LICENSE AND COPYRIGHT

Copyright 2010-2015 Breno G. de Oliveira.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


