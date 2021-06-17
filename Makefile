.PHONY: clean All

All:
	@echo "----------Building project:[ CodeProjects - Debug ]----------"
	@"$(MAKE)" -f  "CodeProjects.mk"
clean:
	@echo "----------Cleaning project:[ CodeProjects - Debug ]----------"
	@"$(MAKE)" -f  "CodeProjects.mk" clean
