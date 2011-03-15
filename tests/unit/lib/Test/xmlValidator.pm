#================
# FILE          : xmlValidator.pm
#----------------
# PROJECT       : OpenSUSE Build-Service
# COPYRIGHT     : (c) 2011 Novell Inc.
#               :
# AUTHOR        : Robert Schweikert <rschweikert@novell.com>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : Unit test implementation for the KIWIXMLValidator module.
#               :
# STATUS        : Development
#----------------
package Test::xmlValidator;

use strict;
use warnings;

use Common::ktLog;
use Common::ktTestCase;
use base qw /Common::ktTestCase/;

use KIWIXMLValidator;

#==========================================
# Constructor
#------------------------------------------
sub new {
	# ...
	# Construct new test case
	# ---
	my $this = shift -> SUPER::new(@_);
	$this -> {dataDir} = $this -> getDataDir() . '/xmlValidator/';
	$this -> {kiwi} = new  Common::ktLog();
	$this -> {schema} = $this -> getBaseDir() . '/../modules/KIWISchema.rng';
	$this -> {xslt} =  $this -> getBaseDir() . '/../xsl/master.xsl';

	return $this;
}

#==========================================
# test_ctorInvalidConfPath
#------------------------------------------
sub test_ctorInvalidConfPath {
	# ...
	# Provide invalid path for configuration file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = new KIWIXMLValidator (
		$kiwi,
		'/tmp',
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		$this -> {xslt}
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified configuration: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
}

#==========================================
# test_ctorInvalidRevPath
#------------------------------------------
sub test_ctorInvalidRevPath {
	# ...
	# Provide invalid path for revision file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = new KIWIXMLValidator (
		$kiwi,
		$this -> {dataDir} . 'genericValid.xml',
		'/tmp',
		$this -> {schema},
		$this -> {xslt}
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified revision file: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
}

#==========================================
# test_ctorInvalidSchemaPath
#------------------------------------------
sub test_ctorInvalidSchemaPath {
	# ...
	# Provide invalid path for schema file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = new KIWIXMLValidator (
		$kiwi,
		$this -> {dataDir} . 'genericValid.xml',
		$this -> {dataDir} . 'revision.txt',
		'/tmp',
		$this -> {xslt}
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified schema: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
}

#==========================================
# test_ctorInvalidXSLTPath
#------------------------------------------
sub test_ctorInvalidXSLTPath {
	# ...
	# Provide invalid path for XSLT file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = new KIWIXMLValidator (
		$kiwi,
		$this -> {dataDir} . 'genericValid.xml',
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		'/tmp'
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified transformation: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
}

#==========================================
# test_ctorValid
#------------------------------------------
sub test_ctorValid {
	# ...
	# Create a valid object
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = new KIWIXMLValidator (
		$kiwi,
		$this -> {dataDir} . 'genericValid.xml',
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		$this -> {xslt}
	);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals('No messages set', $msg);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('none', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('No state set', $state);
	# Test this condition last to get potential error messages
	$this -> assert_not_null($validator);
}

#==========================================
# test_defaultProfileSpec
#------------------------------------------
sub test_defaultProfileSpec {
	# ...
	# Test that the one default profile setting requirement is properly
	# enforced
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('defaultProfile');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Only one profile may be set as the dafault '
		. 'profile by using the "import" attribute.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('defaultProfile');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_defaultTypeSpec
#------------------------------------------
sub test_defaultTypeSpec {
	# ...
	# Test that the one default <type> per <preferences> spec is properly
	# enforced
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('defaultType');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals(
			'Only one primary type may be specified per preferences section.',
			$msg
		);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('defaultType');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_displayName
#------------------------------------------
sub test_displayName {
	# ...
	# Test that the display name condition is properly checked.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('displayName');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Found white space in string provided as '
		. 'displayname. No white space permitted';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('displayName');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_ec2Regions
#------------------------------------------
sub test_ec2Regions {
	# ...
	# Test that the region names and uniqueness conditions are properly
	# enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('ec2Region');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg;
		my @supportedRegions=qw /AP-Japan AP-Singapore EU-West US-East US-West/;
		if ( $iConfFile =~ 'ec2RegionInvalid_1.xml' ) {
			$expectedMsg = 'Specified region EU-West not unique';
		} else {
			$expectedMsg = "Only one of @supportedRegions may be specified "
			. 'as ec2region';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('ec2Region');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_missingFilesysAttr
#------------------------------------------
sub test_missingFilesysAttr {
	# ...
	# Test that the oem post dump action uniqueness is properly
	# enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('missingFilesysAttr');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'filesystem attribute must be set for image="';
		if ($iConfFile =~ /missingFilesysAttrInvalid_1.xml/) {
			$expectedMsg .= 'oem"';
		} elsif ($iConfFile =~ /missingFilesysAttrInvalid_2.xml/) {
			$expectedMsg .= 'vmx"';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('missingFilesysAttr');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_oemPostDump
#------------------------------------------
sub test_oemPostDump {
	# ...
	# Test that the oem post dump action uniqueness is properly
	# enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('oemPostDump');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Use one of oem-bootwait oem-reboot '
		. 'oem-reboot-interactive oem-shutdown oem-shutdown-interactive';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('oemPostDump');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_patternTattrConsistent
#------------------------------------------
sub test_patternTattrConsistent {
	# ...
	# Test that the patternType attribute consistency criteria is
	# properly enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('patternTattrCons');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg;
		if ($iConfFile =~ /patternTattrConsInvalid_1.xml/) {
			$expectedMsg = 'Conflicting patternType attribute values for '
			. '"my-second" profile found.';
		} elsif ($iConfFile =~ /patternTattrConsInvalid_2.xml/) {
			$expectedMsg = 'Conflicting patternType attribute values for '
			. '"my-first" profile found.';
		} elsif ($iConfFile =~ /patternTattrConsInvalid_3.xml/) {
			$expectedMsg = 'The specified value "plusRecommended" for the '
			. 'patternType attribute differs from the specified default '
			. 'value: "onlyRequired".';
		} elsif ($iConfFile =~ /patternTattrConsInvalid_4.xml/) {
			$expectedMsg = 'The patternType attribute was omitted, but the '
			. 'base <packages> specification requires "plusRecommended" '
			. 'the values must match.';
		} else {
			# Force a test failure, there is no generic message in this test
			# stream
			$expectedMsg = 'ola';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('patternTattrCons');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_patternTattrUse
#------------------------------------------
sub test_patternTattrUse {
	# ...
	# Test that the patternType attribute use criteria is properly
	# enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('patternTattrUse');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'The patternType atribute is not allowed on a '
		. '<packages> specification of type delete.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('patternTattrUse');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_preferenceUnique
#------------------------------------------
sub test_preferenceUnique {
	# ...
	# Test that the <preferences> element uniqueness criteria is properly
	# enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('preferenceUnique');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg;
		if ($iConfFile =~ /preferenceUniqueInvalid_1.xml/) {
			$expectedMsg = 'Specify only one <preferences> element without '
		. 'using the "profiles" attribute.';
		} elsif ($iConfFile =~ /preferenceUniqueInvalid_2.xml/) {
			$expectedMsg = 'Only one <preferences> element may reference a '
			. 'given profile. xenFlavour referenced multiple times.';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('preferenceUnique');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_profileName
#------------------------------------------
sub test_profileName {
	# ...
	# Test that the profile name convention is enforced properly.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('profileName');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg ;
		if ($iConfFile =~ /profileNameInvalid_2.xml/) {
			$expectedMsg = 'Name of a profile may not be set to "all".';
		} else {
			$expectedMsg = 'Name of a profile may not contain whitespace.';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('profileName');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_profileReferenceExist
#------------------------------------------
sub test_profileReferenceExist {
	# ...
	# Test that the existens requirement for a referenced profile is
	# properly enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('profileReferenceExist');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Found reference to profile "';
		if ($iConfFile =~ /profileReferenceExistInvalid_(1|2).xml/) {
			$expectedMsg .= 'ec2Flavour';
		} elsif ($iConfFile =~ /profileReferenceExistInvalid_(3|4).xml/) {
			$expectedMsg .= 'ola';
		}
		$expectedMsg .= '" but this profile is not defined.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('profileReferenceExist');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_revisionMismatch
#------------------------------------------
sub test_revisionMismatch {
	# ...
	# Test mismatch between specified revision and encoded revision
	# ---
	my $this = shift;
	my $validator = $this -> __getValidator(
		$this -> {dataDir} . 'improperRevision.xml'
	);
	$validator -> validate();
	my $kiwi = $this -> {kiwi};
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		"KIWI revision too old, require r3 got r1\n",$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	# Test this condition last to get potential error messages
	$this -> assert_not_null($validator);
}

#==========================================
# test_typeUnique
#------------------------------------------
sub test_typeUnique {
	# ...
	# Test that the image type uniqueness requirement is
	# properly enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('typeUnique');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Multiple definition of <type image="';
		if ($iConfFile =~ /typeUniqueInvalid_1.xml/) {
			$expectedMsg .= 'iso';
		} elsif ($iConfFile =~ /typeUniqueInvalid_2.xml/) {
			$expectedMsg .= 'oem';
		}
		$expectedMsg .= '".../> found.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('typeUnique');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# test_versionFormat
#------------------------------------------
sub test_versionFormat {
	# ...
	# Test that the version number format requirement is
	# properly enforced.
	# ---
	my $this = shift;
	my @invalidConfigs = $this -> __getInvalidFiles('versionFormat');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = "Expected 'Major.Minor.Release'";
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('versionFormat');
	$this -> __verifyValid(@validConfigs);
}

#==========================================
# Private helper methods
#------------------------------------------
#==========================================
# __getInvalidFiles
#------------------------------------------
sub __getInvalidFiles {
	# ...
	# Helper to get a list of invalid files with $(prefix)Invalid_*.xml
	# naming convention.
	# ---
	my $this   = shift;
	my $prefix = shift;
	return glob $this -> {dataDir} . $prefix . 'Invalid_*.xml';
}

#==========================================
# __getValidator
#------------------------------------------
sub __getValidator {
	# ...
	# Helper function to create a KIWIXMLValidator object
	# ---
	my $this         = shift;
	my $confFileName = shift;
	my $validator = new KIWIXMLValidator (
		$this -> {kiwi},
		$confFileName,
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		$this -> {xslt}
	);
	return $validator;
}

#==========================================
# __getValidFiles
#------------------------------------------
sub __getValidFiles {
	# ...
	# Helper to get a list of invalid files with $(prefix)Valid_*.xml
	# naming convention.
	# ---
	my $this   = shift;
	my $prefix = shift;
	return glob $this -> {dataDir} . $prefix . 'Valid_*.xml';
}

#==========================================
# __verifyValid
#------------------------------------------
sub __verifyValid {
	# ...
	# Helper to verify a list of valid config files.
	# This is common to all test cases as each XML validation is validated
	# with faling and vaild conditions. For valid configuration files
	# the state of the logging mechanism is always the same, thus this is
	# common to all test cases.
	# ---
	my $this = shift;
	my @validConfigs = @_;
	for my $vConfFile (@validConfigs) {
		my $validator = $this -> __getValidator($vConfFile);
		$validator -> validate();
		my $kiwi = $this -> {kiwi};
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals('No messages set', $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('none', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('No state set', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
}

1;