include(`macros.m4')
DONT_CHANGE()
FROM php:7.4-zts-alpine3.11

include(`php-ext-7.4.m4')
include(`composer.m4')
include(`php-ext-cleanup.m4')
include(`cli.m4')