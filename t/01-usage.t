use Test::More;

use WWW::Correios::SRO;
use URI::file;

my $uri = URI::file->new_abs('t/SRO.html');

my @tracker = WWW::Correios::SRO::sro(0, $uri);
my $single  = WWW::Correios::SRO::sro(0, $uri);

is(scalar @tracker, 10, 'found 10 entries');
foreach (@tracker) {
    isa_ok($_, 'WWW::Correios::SRO::Item');
    can_ok($_, qw(data date location local status extra));
}

is_deeply($single, $tracker[0], 'checking single-wantarray results');

### item 0
is($tracker[0]->data, '24/05/2010 09:50', '[0] correct date');
is($tracker[0]->date, '24/05/2010 09:50', '[0] correct date (2)');
is($tracker[0]->local, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[0] correct location');
is($tracker[0]->location, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[0] correct location (2)');
is($tracker[0]->status, 'Entregue', '[0] correct status');
is($tracker[0]->extra, undef, '[0] correct extra');

### item 1
is($tracker[1]->data, '24/05/2010 08:42', '[1] correct date');
is($tracker[1]->date, '24/05/2010 08:42', '[1] correct date (2)');
is($tracker[1]->local, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[1] correct location');
is($tracker[1]->location, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[1] correct location (2)');
is($tracker[1]->status, 'Saiu para entrega', '[1] correct status');
is($tracker[1]->extra, undef, '[0] correct extra');

### item 2
is($tracker[2]->data, '22/05/2010 12:10', '[2] correct date');
is($tracker[2]->date, '22/05/2010 12:10', '[2] correct date (2)');
is($tracker[2]->local, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[2] correct location');
is($tracker[2]->location, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[2] correct location (2)');
is($tracker[2]->status, 'Destinatário ausente', '[2] correct status');
is($tracker[2]->extra, 'Será realizada uma nova tentativa de entrega.', '[2] correct extra');

### item 3
is($tracker[3]->data, '22/05/2010 11:19', '[3] correct date');
is($tracker[3]->date, '22/05/2010 11:19', '[3] correct date (2)');
is($tracker[3]->local, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[3] correct location');
is($tracker[3]->location, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[3] correct location (2)');
is($tracker[3]->status, 'Saiu para entrega', '[3] correct status');
is($tracker[3]->extra, undef, '[3] correct extra');

### item 4
is($tracker[4]->data, '22/05/2010 09:22', '[4] correct date');
is($tracker[4]->date, '22/05/2010 09:22', '[4] correct date (2)');
is($tracker[4]->local, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[4] correct location');
is($tracker[4]->location, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[4] correct location (2)');
is($tracker[4]->status, 'Destinatário ausente', '[4] correct status');
is($tracker[4]->extra, 'Será realizada uma nova tentativa de entrega.', '[4] correct extra');

### item 5
is($tracker[5]->data, '22/05/2010 08:17', '[5] correct date');
is($tracker[5]->date, '22/05/2010 08:17', '[5] correct date (2)');
is($tracker[5]->local, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[5] correct location');
is($tracker[5]->location, 'CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[5] correct location (2)');
is($tracker[5]->status, 'Saiu para entrega', '[5] correct status');
is($tracker[5]->extra, undef, '[5] correct extra');

### item 6
is($tracker[6]->data, '22/05/2010 05:38', '[6] correct date');
is($tracker[6]->date, '22/05/2010 05:38', '[6] correct date (2)');
is($tracker[6]->local, 'CTE BENFICA - RIO DE JANEIRO/RJ', '[6] correct location');
is($tracker[6]->location, 'CTE BENFICA - RIO DE JANEIRO/RJ', '[6] correct location (2)');
is($tracker[6]->status, 'Encaminhado', '[6] correct status');
is($tracker[6]->extra, 'Em trânsito para CEE LARANJEIRAS - RIO DE JANEIRO/RJ', '[6] correct extra');

### item 7
is($tracker[7]->data, '21/05/2010 20:23', '[7] correct date');
is($tracker[7]->date, '21/05/2010 20:23', '[7] correct date (2)');
is($tracker[7]->local, 'CTCE VITORIA - VITORIA/ES', '[7] correct location');
is($tracker[7]->location, 'CTCE VITORIA - VITORIA/ES', '[7] correct location (2)');
is($tracker[7]->status, 'Encaminhado', '[7] correct status');
is($tracker[7]->extra, 'Em trânsito para CTE BENFICA - RIO DE JANEIRO/RJ', '[7] correct extra');

### item 8
is($tracker[8]->data, '21/05/2010 17:43', '[8] correct date');
is($tracker[8]->date, '21/05/2010 17:43', '[8] correct date (2)');
is($tracker[8]->local, 'ACF ESPLANADA - VITORIA /ES', '[8] correct location');
is($tracker[8]->location, 'ACF ESPLANADA - VITORIA /ES', '[8] correct location (2)');
is($tracker[8]->status, 'Encaminhado', '[8] correct status');
is($tracker[8]->extra, 'Em trânsito para CTCE VITORIA - VITORIA/ES', '[8] correct extra');

### item 9
is($tracker[9]->data, '21/05/2010 16:41', '[9] correct date');
is($tracker[9]->date, '21/05/2010 16:41', '[9] correct date (2)');
is($tracker[9]->local, 'ACF ESPLANADA - VITORIA /ES', '[9] correct location');
is($tracker[9]->location, 'ACF ESPLANADA - VITORIA /ES', '[9] correct location (2)');
is($tracker[9]->status, 'Postado', '[9] correct status');
is($tracker[9]->extra, undef, '[9] correct extra');


### SECOND SAMPLE (was failing in 0.1)
$uri = URI::file->new_abs('t/SRO2.html');

@tracker = WWW::Correios::SRO::sro(0, $uri);
$single  = WWW::Correios::SRO::sro(0, $uri);

is(scalar @tracker, 2, 'found 2 entries in sample #2');
foreach (@tracker) {
    isa_ok($_, 'WWW::Correios::SRO::Item');
    can_ok($_, qw(data date location local status extra));
}

is_deeply($single, $tracker[0], 'checking single-wantarray results in sample #2');

### item 0
is($tracker[0]->data, '22/08/2011 20:51', '[0] correct date in sample #2');
is($tracker[0]->date, '22/08/2011 20:51', '[0] correct date (2) in sample #2');
is($tracker[0]->local, 'CHINA - CHINA', '[0] correct location in sample #2');
is($tracker[0]->location, 'CHINA - CHINA', '[0] correct location (2) in sample #2');
is($tracker[0]->status, 'Encaminhado', '[0] correct status in sample #2');
is(
    $tracker[0]->extra,
    'Em trânsito para UNIDADE DE TRATAMENTO INTERNACIONAL - BRASIL',
    '[0] correct extra in sample #2'
);


done_testing;
