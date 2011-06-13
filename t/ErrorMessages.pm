package t::ErrorMessages;
@ISA = ("Exporter");
use strict;
use Exporter ();

sub _invalid_argument   {sprintf("Invalid argument: %s",@_)}
sub _required           {sprintf("Required option '%s' not found",@_)}
sub _switch_twice       {sprintf("Switch used twice: %s",@_)}
sub _switch_value       {sprintf("Switch can't take a value: %s=%s",@_)}
sub _counter_value      {sprintf("Counter option can't take a value: %s=%s",@_)}
sub _param_ambiguous    {sprintf("Ambiguous value for %s could be option: %s",@_)}
sub _param_invalid      {sprintf("Invalid parameter %s = %s",@_)}
sub _param_neg_value    {sprintf("Negated parameter option can't take a value: %s=%s",@_)}
sub _list_invalid       {sprintf("Invalid list option %s = %s",@_)}
sub _keypair_invalid    {sprintf("Invalid keypair '%s': %s => %s",@_)}
sub _list_ambiguous     {sprintf("Ambiguous value for %s could be option: %s",@_)}
sub _keypair            {sprintf("Badly formed keypair for '%s'",@_)}
sub _default_list       {sprintf("Default for list '%s' must be array reference",@_)}
sub _default_keypair    {sprintf("Default for keypair '%s' must be hash reference",@_)}
sub _default_invalid    {sprintf("Default '%s' = '%s' fails to validate",@_)}
sub _name_invalid       {sprintf("'%s' is not a valid option name/alias",@_)}
sub _name_not_unique    {sprintf("'%s' is not unique",@_)}
sub _name_conflicts     {sprintf("'%s' conflicts with other options",@_)}
sub _key_invalid        {sprintf("'%s' is not a valid option specification key",@_)}
sub _type_invalid       {sprintf("'%s' is not a valid option type",@_)}
sub _prereq_missing     {sprintf("Option '%s' requires option '%s'",@_)} 
sub _unknown_prereq     {sprintf("Prerequisite '%s' for '%s' is not recognized",@_)} 
sub _invalid_list       {sprintf("Option '%s' in %s must be scalar or array reference",@_)}
sub _invalid_keypair    {sprintf("Option '%s' in %s must be scalar or hash reference",@_)}
sub _invalid_splat_defaults {sprintf("Argument to %s must be a hash or hash reference",@_)}
sub _no_value           {sprintf("Option '%s' requires a value",@_)}

# keep this last;
for (keys %t::ErrorMessages::) {
    push @t::ErrorMessages::EXPORT, $_ if $_ =~ "^_";
}

1; 
