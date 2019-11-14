# MouseX-AttributeTraitHelper

If you needs to use many traits for attribute with overlapped field name this solution for you!

This role replace all trait for attribute by one new trait. For example:

You have two traits:

```perl
package Trait1;
use Mouse::Role;

has 'allow' => (isa => 'Int', default => 123);

no Mouse::Role;

package Trait2;
use Mouse::Role;

has 'allow' => (isa => 'Str', default => 'qwerty');

no Mouse::Role;
```

Both add fields to attribute with same name. In this case Mouse throw the exception:
 "We have encountered an attribute conflict with 'allow' during composition. This is fatal error and cannot be disambiguated."

Use '+' before role attribute was not supported.

Solution:

```perl
package ClassWithTrait;
use Mouse -traits => 'MouseX::AttributeTraitHelper::Merge';

has attrib => (
    is => 'rw',
    isa => 'Int',
    traits => ['Trait1', 'Trait2'],
);

no Mouse;
__PACKAGE__->meta->make_immutable();
```

In this case Trait1 and Trait2 merged in MouseX::AttributeTraitHelper::Merge::Trait1::Trait2 and applied to atribute `attrib`.
The last `Trait` in the list is the highest priority and rewrite attribute fields.

In this case attribute `attrib` has field `allow` with type `Str` and dafault value `qwerty`.

But method `does` still work correctly:
`ClassWithTrait->meta->get_attribute('attrib')->does('Trait1')` or `ClassWithTrait->meta->get_attribute('attrib')->does('Trait2')` returns true

The last may confuse the developer because `Trait1` exports the `allow` field of type `Int`, but ultimately `allow` is of type `Str`

