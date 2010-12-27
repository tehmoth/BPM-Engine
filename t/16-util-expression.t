use strict;
use warnings;
use lib './t/lib';
use Test::More;
use Test::Exception;

use BPM::Engine::Util::ExpressionEvaluator;
{
my $evaluator = BPM::Engine::Util::ExpressionEvaluator->load(
    count => 2,
    );

is($evaluator->evaluate(1), 1);
is($evaluator->evaluate(0), 0);
is($evaluator->evaluate('0'), 0);
is($evaluator->evaluate(undef), 0);
is($evaluator->evaluate(), 0);
is($evaluator->evaluate(0.0), 0);
is($evaluator->evaluate('0.0'), 0);
is($evaluator->evaluate(''), 0);

# for tt these are just undefined vars
is($evaluator->evaluate('false'), 0); 
is($evaluator->evaluate('true'), 0);

is($evaluator->evaluate('NULL'), 0);
is($evaluator->evaluate('null'), 0);
is($evaluator->evaluate('NOT NULL'), 1);
is($evaluator->evaluate('not nULl'), 1);
is($evaluator->evaluate('!NULL'), 1);
is($evaluator->evaluate('!1'), 0);
is($evaluator->evaluate('!0'), 1);

ok($evaluator->evaluate('count == 2'));
ok(!$evaluator->evaluate('count == 3'));

$evaluator->set_param(count => 3);
ok($evaluator->evaluate('count == 3'));
ok($evaluator->evaluate('count == 3 or count == 2'));

is($evaluator->evaluate('count == 3'), 1);

is($evaluator->parse('count'), 3);
is($evaluator->parse(q/'count ' _ count _ ' is ' _ "$count"/), 'count 3 is 3');
is($evaluator->parse('"count $count is ${count}"'), 'count 3 is 3');
}

{
my $attr = {
    splitA => undef,
    splitB => 'C',
    };
my $evaluator = BPM::Engine::Util::ExpressionEvaluator->load(
                attributes         => $attr,
                #process           => $pi->process,
                #process_instance  => $pi,
                #activity          => $activity,
                #activity_instance => $activity_instance,
                #transition        => $transition,
                #args              => [@args],
                );

is($evaluator->evaluate("!attributes.splitA"), 1);
is($evaluator->evaluate("!attributes.splitB"), 0);
throws_ok( sub { $evaluator->evaluate("attributes.splitB") }, 'BPM::Engine::Exception::Expression', 'exception thrown' );
is($evaluator->parse("attributes.splitB.match('B1')"),'');

lives_ok( sub { $evaluator->evaluate("attributes.splitB.match('B1')") }, 'no exception thrown' );
throws_ok( sub { $evaluator->evaluate("attributes.splitB.match('C')") }, 'BPM::Engine::Exception::Expression', 'exception thrown' );

is($evaluator->evaluate("attributes.splitB.search('B1')"), 0);
is($evaluator->evaluate("attributes.splitB.search('C')"), 1);

#$evaluator->parse("process_instance.attribute(customer_type => 'whale')");

}


done_testing();
