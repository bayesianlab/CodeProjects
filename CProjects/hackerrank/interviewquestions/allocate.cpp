#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Descriptor
{
    int id;
    int name_length;
    char *name;
} Descriptor;

Descriptor *allocate_and_initialize_descriptor(int id, const char *name) 
{
    Descriptor *newdescriptor = new Descriptor; 
    newdescriptor->id = id; 
    newdescriptor->name=  strdup(name);
    newdescriptor->name_length = strlen(newdescriptor->name);
    return newdescriptor;
}

void deallocate_descriptor(Descriptor *descriptor)
{
    delete[] descriptor->name;

}

#ifndef RunTests
int main()
{
    Descriptor *descriptor = allocate_and_initialize_descriptor(2, "File");
    printf("Id: %d, name length: %d, name: %s", descriptor->id, descriptor->name_length, descriptor->name);
    deallocate_descriptor(descriptor);
}
#endif