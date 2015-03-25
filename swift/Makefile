
SOURCES_BASE =  types.swift
SOURCES_LISP =  step8_macros.swift
SOURCES = $(SOURCES_BASE) $(SOURCES_LISP)



.PHONY: stats tests $(TESTS)

stats: $(SOURCES)
	@wc $^
stats-lisp: $(SOURCES_LISP)
	@wc $^

tests: $(TESTS)

$(TESTS):
	@echo "Running $@"; \
	swiftthon $@ || exit 1; \
