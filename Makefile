# makedjvu - produce a DjVu book from a set of page images.

# Copyright (C) 2021  Pavel Avrorov <avrorov@priboy.online>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

PAGESUF = .tif
PAGEDIR = $(if $(wildcard out),out,.)
C44 = c44
CJB2 = cjb2
CONVERT = convert
DJVUMAKE = djvumake
DJVUEXTRACT = djvuextract
DJVM = djvm
C44_OPTS =
CJB2_OPTS = -lossy -clean
THRESHOLD = 1%
COVER_DPI = 100

PAGEFILES = $(sort $(wildcard $(PAGEDIR)/*$(PAGESUF)))
BILEVELS = $(shell identify $(PAGEFILES) | sed -n -e '/Bilevel/ { s/^\(.*\$(PAGESUF)\)[[:space:]].*$$/\1/p; }')
MIXED = $(shell identify $(PAGEFILES) | sed -n -e '/Bilevel/ d' -e 's/^\(.*\$(PAGESUF)\)[[:space:]].*$$/\1/p')
COVERS = $(if $(MIXED),$(if $(filter $(firstword $(MIXED)),$(firstword $(PAGEFILES))),$(firstword $(MIXED))) $(if $(filter $(lastword $(MIXED)),$(lastword $(PAGEFILES))),$(lastword $(MIXED))))
PAGES = $(BILEVELS) $(MIXED)

PATHNAME = $(shell echo $(abspath $(PAGEDIR)) | tr '[\t ]' '_')
NAME = $(notdir $(if $(filter .,$(PAGEDIR)),$(PATHNAME),$(patsubst %/,%,$(dir $(PATHNAME)))))
FILENAME = $(patsubst %.,%,$(NAME)).djvu
WORKDIR = djvudir

djvu: info $(FILENAME)

info:
	@echo 'Book name: $(FILENAME)'
#	$(if $(BILEVELS),@echo 'Bilevel pages: $(BILEVELS)')
	$(if $(MIXED),@echo 'Mixed pages: $(MIXED)')
	$(if $(COVERS),@@echo 'Cover pages: $(COVERS)')
	@echo 'C44 options: $(if $(C44_OPTS),$(C44_OPTS),(default))'
	@echo 'CJB2 options: $(if $(CJB2_OPTS),$(CJB2_OPTS),(default))'
	@echo 'Mask threshold: $(THRESHOLD)'
	$(if $(COVERS),@@echo 'Cover dpi: $(COVER_DPI)')
	@echo 'Workdir: $(WORKDIR)'

DJVUPAGES = $(patsubst $(PAGEDIR)/%$(PAGESUF),$(WORKDIR)/%.bw.djvu,$(BILEVELS)) \
			$(patsubst $(PAGEDIR)/%$(PAGESUF),$(WORKDIR)/%.mixed.djvu,$(MIXED))
$(FILENAME): $(DJVUPAGES)
	$(DJVM) -c $@ $(sort $(DJVUPAGES))


# Downsample cover pages

define cover_page_template =
 $$(WORKDIR)/$(1).dpi: | workdir
	echo '$$(COVER_DPI)' >$$@
 $$(WORKDIR)/$(1).ppm: $$(PAGEDIR)/$(1)$$(PAGESUF) | workdir
	$$(CONVERT) $$< -resample $$(COVER_DPI) $$@
endef
$(foreach cover,$(notdir $(basename $(COVERS))),$(eval $(call cover_page_template,$(cover))))


# Produce bilevel pages

$(WORKDIR)/%.bw.djvu: $(PAGEDIR)/%$(PAGESUF) | workdir
	$(CJB2) $(CJB2_OPTS) $< $@


# Mixed pages (covers and pages with tonal images)

$(WORKDIR)/%.dpi: $(PAGEDIR)/%$(PAGESUF) | workdir
	identify -format '%x\n' $< >$@

$(WORKDIR)/%.ppm: $(PAGEDIR)/%$(PAGESUF) | workdir
	$(CONVERT) $< $@

$(WORKDIR)/%.mask.pbm: $(WORKDIR)/%.ppm | workdir
	$(CONVERT) $< -threshold $(THRESHOLD) $@

$(WORKDIR)/%.mask.djvu: $(WORKDIR)/%.mask.pbm $(WORKDIR)/%.dpi | workdir
	$(CJB2) -dpi $(shell cat $(WORKDIR)/$*.dpi) $(CJB2_OPTS) $< $@

$(WORKDIR)/%.bg.djvu: $(WORKDIR)/%.ppm $(WORKDIR)/%.mask.pbm $(WORKDIR)/%.dpi | workdir
	$(C44) -dpi $(shell cat $(WORKDIR)/$*.dpi) $(C44_OPTS) -mask $(WORKDIR)/$*.mask.pbm $< $@

$(WORKDIR)/%.bg.iw44: $(WORKDIR)/%.bg.djvu
	$(DJVUEXTRACT) $< BG44=$@

$(WORKDIR)/%.mixed.djvu: $(WORKDIR)/%.bg.iw44 $(WORKDIR)/%.mask.djvu | workdir
	$(DJVUMAKE) $@ INFO=,,$(shell cat $(WORKDIR)/$*.dpi) Sjbz=$(WORKDIR)/$*.mask.djvu BG44=$(WORKDIR)/$*.bg.iw44

workdir: $(WORKDIR)

$(WORKDIR):
	mkdir -p $(WORKDIR)

clean:
	rm -rf $(WORKDIR)

.PHONY: info

.DELETE_ON_ERROR:
