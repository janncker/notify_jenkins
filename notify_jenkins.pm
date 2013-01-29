# Copyright (C) 2012, Intel Corporation.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.

# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.

# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place - Suite 330, Boston, MA 02111-1307 USA.

################################################################
#
# Module to talk to Jenkins
#
# Add the following lines to BSConfig.pm to enable this plugin
#    our $jenkinsserver = "http://you.jenkins.server.com";
#    our $jenkinsjob = "job/JOB_NAME/buildWithParameters";
#    our $jenkinsnamespace = "OBS";
#    our $notification_plugin = "notify_jenkins";
#    our @interested_events = ("REPO_PUBLISHED", "SRCSRV_REQUEST_CREATE");

package notify_jenkins;

use BSRPC;
use BSConfig;
use MIME::Base64;
use strict;
use JSON::XS;

sub new {
  my $self = {};
  bless $self, shift;
  return $self;
}

sub notify() {
  my ($self, $type, $paramRef ) = @_;
  die('No jenkinssever configured in BSConfig!') unless $BSConfig::jenkinsserver;
  die('No interested events array configured in BSConfig!') unless @BSConfig::interested_events;
  die('No jenkinsjob configured in BSConfig!' ) unless $BSConfig::jenkinsjob;


  return unless grep(/^$type$/, @BSConfig::interested_events);

  my $args = {};

  $type = "UNKNOWN" unless $type;

  # prepend something BS specific
  my $prefix = $BSConfig::jenkinsnamespace|| "OBS";
  $type =  "${prefix}_$type";
  $args->{'event_type'} = $type;
  if ($paramRef) {
    for my $key (sort keys %$paramRef) {
      next if ref $paramRef->{$key};
      $args->{$key} = $paramRef->{$key} if defined $paramRef->{$key};
    }
  }
  my $jenkinsuri = "$BSConfig::jenkinsserver/$BSConfig::jenkinsjob";
  my $param = {
    'uri' => $jenkinsuri,
    'timeout' => 60,
    'maxredirects' => 1,
  };

  my $project;
  if (defined $args->{'project'}){
      $project = $args->{'project'};
  }
  elsif (defined $args->{'targetproject'}) {
      $project = $args->{'targetproject'};
  }else{
      warn("No project name found in events");
      return;
  }

  my @para = ("project=$args->{'project'}",
              "event_type=$type",
              "para=" . encode_base64(encode_json($args),''));
  eval {
    BSRPC::rpc( $param, undef, @para );
  };
  warn("Jenkins: $@") if $@;
}

1;
