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
our @EXPORT_OK = qw( sro sro_en );

our $VERSION = '0.01';
my $AGENT = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
my $TIMEOUT = 30;

sub sro    { _sro('001', @_) }
sub sro_en { _sro('002', @_) }

sub _sro {
    my ($LANG, $code, $_url) = @_;

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
    my @items = $html->find('table')->find('tr');
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

    use WWW::Correios::SRO 'sro';

    my @historico_completo = sro( 'SS123456789BR' );

    my $ultimo = sro( 'SS123456789BR' );

    $ultimo->data;    # '22/05/2010 12:10'
    $ultimo->local;   # 'CEE JACAREPAGUA - RIO DE JANEIRO/RJ'
    $ultimo->status;  # 'Destinatário ausente'
    $ultimo->extra;   # 'Será realizada uma nova tentativa de entrega'

English API:

    use WWW::Correios::SRO 'sro_en';

    my @historico_completo = sro_en( 'SS123456789BR' );

    my $ultimo = sro_en( 'SS123456789BR' );

    $ultimo->date;       # '22/05/2010 12:10'
    $ultimo->location;   # 'CEE JACAREPAGUA - RIO DE JANEIRO/RJ'
    $ultimo->status;     # 'No receiver at the address'
    $ultimo->extra;      # 'Delivery will be retried'

Note: All messages are created by the brazilian post office website. Some messages might not be translated.

Note #2: the sro_en() function is experimental, and could be removed in future versions with no prior notice. If you care, or have any comments/suggestions on how to improve this, please let me know.

=head1 DESCRIPTION


=head1 EXPORTS

Este módulo não exporta nada por padrão. Você precisa explicitar 'sro' (para mensagens em português) ou 'sro_en' (para mensagens em inglês).

This module exports nothing by default. You have to explicitly ask for 'sro' (for the portuguese messages) or 'sro_en' (for the english messages).

=head2 sro

Recebe o código identificador do objeto. 

Em contexto escalar, retorna retorna um objeto WWW::Correios::SRO::Item contento a entrada mais recente no registro dos Correios. Em contexto de lista, retorna um array de objetos WWW::Correios::SRO::Item, da entrada mais recente à mais antiga. Em caso de falha, retorna I<undef>. As mensagens do objeto retornado estarão em português.

--

Receives the item identification code.

In scalar context, returns a WWW::Correios::SRO::Item object containing the most recent log entry in the Postal service. In list context, returns a list of WWW::Correios::SRO::Item objects, from the most recent entry to the oldest. Returns I<undef> upon failure. Messages on the returned object will be in portuguese.

=head2 sro_en

O mesmo que C<sro()>, mas com mensagens em inglês.

Same as C<sro()>, but with messages in english.


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



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Correios::SRO


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Correios-SRO>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Correios-SRO>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Correios-SRO>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Correios-SRO/>

=back


=head1 AGRADECIMENTOS/ACKNOWLEDGEMENTS

Este módulo não existiria sem o serviço gratuito de rastreamento online dos Correios. 

L<< http://www.correios.com.br/servicos/rastreamento/ >>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Breno G. de Oliveira.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


