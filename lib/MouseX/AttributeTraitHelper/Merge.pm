package MouseX::AttributeTraitHelper::Merge;
use Mouse::Role;

around add_attribute => sub {
    my ($orig, $self) = (shift, shift);

    if(Scalar::Util::blessed($_[0])){
        $self->$orig($_[0]);
    }
    else{
        my $name = shift;
        my %args = (@_ == 1) ? %{$_[0]} : @_;

        defined($name)
            or $self->throw_error('You must provide a name for the attribute');

        my $traits = delete $args{traits};
        my $name_merged_trait = join "::" , 'MouseX::AttributeTraitHelper::Merge' , @$traits;
        my $meta = Mouse::Role->init_meta(for_class => $name_merged_trait);
        for my $trait (@$traits) {
            for my $trait_attr_name ($trait->meta->get_attribute_list()) {
                my $trait_attr = $trait->meta->get_attribute($trait_attr_name);
                $trait_attr_name =~ s/^\+//;
                my $exist_trait_attr = $meta->get_attribute($trait_attr_name);
                if ($exist_trait_attr) {
                    @$exist_trait_attr{keys %$trait_attr} = values %$trait_attr;
                }
                else {
                    $meta->add_attribute($trait_attr_name => {is => 'ro', %$trait_attr});
                }
            }
        }
        $args{traits} = [$meta->name];
        return $self->$orig($name, %args);
    }
};

no Mouse::Role;
1;
