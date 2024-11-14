<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<!-- PAGE TYPE LISTS (NOT PACKAGE PAGES) -->
<!-- Add % for exact match -->

<!-- INFO PAGES LIST -->
<xsl:variable name="info_pages">
	%whichsections%
	%conventions%
	%version%
	%mirrors%
	%packages%
	%changelog%
	%maillists%
	%wiki%
	%askhelp%
	%credits%
	%contactinfo%
	%unpacking%
	%position%
	%patches%
	%systemd-units%
	%la-files%
	%libraries%
	%locale-issues%
	%beyond%
	%postlfs-config-bootdisk%
	%postlfs-console-fonts%
	%postlfs-firmware%
	%postlfs-devices%
	%postlfs-config-skel%
	%postlfs-users-groups%
	%postlfs-config-logon%
	%vulnerabilities%
	%fw-firewall%
	%aboutlvm%
	%raid%
	%grub-setup%
	%gitserver%
	%svnserver%
	%advanced-network%
	%wireless-kernel%
	%basicnet-mailnews-other%
	%upgradedb%
	%xorg7%
	%xorg-config%
	%tuning-fontconfig%
	%TTF-and-OTF-fonts%
	%kde-add-pkgs%
	%alsa%
</xsl:variable>

<!-- COMMAND PAGES LIST -->
<xsl:variable name="command_pages">
	%postlfs-config-profile%
	%postlfs-config-vimrc%
	%kde-intro%
	%kf6-intro%
	%lxqt-pre-install%
	%lxqt-post-install%
</xsl:variable>

<!-- DEPS (python, perl) PAGES LIST -->
<xsl:variable name="deps_pages">
	%perl-deps%
	%python-dependencies%
</xsl:variable>

<!-- MODULES (python, perl) PAGES LIST -->
<xsl:variable name="modules_pages">
	%perl-modules%
	%python-modules%
</xsl:variable>

<!-- LIST PAGES LIST -->
<xsl:variable name="list_pages">
	%xorg7-lib%
	%xorg7-app%
	%xorg7-font%
	%xorg7-legacy%
	%kf6-frameworks%
	%plasma-build%
</xsl:variable>






<xsl:template match="/">

	<xsl:apply-templates select="book/part/chapter/sect1" />

</xsl:template>






<xsl:template match="sect1">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="title" />|<xsl:value-of select="@id" />

	<!-- PROCESS PAGE TYPES -->
	<!-- Add % for exact match -->
	<xsl:variable name="id" select="concat('%',@id,'%')" />
	<xsl:choose>
		
		<!-- EMPTY ID -->
		<xsl:when test="not(@id)">
			<xsl:apply-templates select="." mode="empty" />
		</xsl:when>

		<!-- INFO PAGE -->
		<xsl:when test="contains($info_pages,$id)">
			<xsl:apply-templates select="." mode="info" />
		</xsl:when>

		<!-- COMMAND PAGE -->
		<xsl:when test="contains($command_pages,$id)">
			<xsl:apply-templates select="." mode="command" />
		</xsl:when>

		<!-- DEPS PAGE -->
		<xsl:when test="contains($deps_pages,$id)">
			<xsl:apply-templates select="." mode="deps" />
		</xsl:when>

		<!-- MODULES PAGE -->
		<xsl:when test="contains($modules_pages,$id)">
			<xsl:apply-templates select="." mode="modules" />
		</xsl:when>

		<!-- LIST PAGE -->
		<xsl:when test="contains($list_pages,$id)">
			<xsl:apply-templates select="." mode="list" />
		</xsl:when>

	</xsl:choose>

</xsl:template>






<xsl:template match="sect1" mode="empty">
	<xsl:text>|EMPTY</xsl:text>
</xsl:template>

<xsl:template match="sect1" mode="info">
	<xsl:text>|INFO</xsl:text>
</xsl:template>

<xsl:template match="sect1" mode="command">
	<xsl:text>|COMMAND</xsl:text>
</xsl:template>

<xsl:template match="sect1" mode="deps">
	<xsl:text>|DEPS</xsl:text>
</xsl:template>

<xsl:template match="sect1" mode="modules">
	<xsl:text>|MODULES</xsl:text>
</xsl:template>

<xsl:template match="sect1" mode="list">
	<xsl:text>|LIST</xsl:text>
</xsl:template>






</xsl:stylesheet>

