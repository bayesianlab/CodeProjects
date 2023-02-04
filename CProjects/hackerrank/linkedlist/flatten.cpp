#include <bits/stdc++.h>
using namespace std;
struct Node
{
    int data;
    struct Node *next;
    struct Node *bottom;

    Node(int x)
    {
        data = x;
        next = NULL;
        bottom = NULL;
    }
};

void printList(Node *Node)
{
    int c = 0;
    while (Node != NULL)
    {
        ++c;
        printf("%d ", Node->data);
        Node = Node->bottom;
    }
    printf("\n");
    printf("nodes %d\n", c);
}

void printL(Node *n)
{
    struct Node *x;
    int c = 0;
    while (n != NULL)
    {
        x = n;
        n = n->next;
        while (x != NULL)
        {
            ++c;
            printf("%d ", x->data);
            x = x->bottom;
        }
        printf("\n");
    }
    printf("nodes %d\n", c);
}

Node *flatten(Node *root)
{
 
    if (root->next != NULL)
    {
        if (root->data > root->next->data)
        {
            struct Node *temproot = root;
            struct Node *tempnextbottom = root->next->bottom;
            struct Node *tempnextnext = root->next->next;
            root = root->next;
            root->bottom = temproot;
            root->next = tempnextbottom;
            tempnextbottom->next = tempnextnext;
            
            root = flatten(root);
        }
        else
        {
            struct Node *temproot = root;
            struct Node *next = root->next;
            struct Node *prev = root;
            while ((root != NULL) && (next->data > root->data))
            {
                prev = root;
                root = root->bottom;
            }
            root = prev;
            struct Node *rootbottom = root->bottom;
            struct Node *nextbottom = next->bottom;
            struct Node *nextnext = next->next;
            root->bottom = next;
            next->bottom = rootbottom;
            next->next = NULL;
            root = temproot;
            if (nextbottom != NULL)
            {
                root->next = nextbottom;
                nextbottom->next = nextnext;
                
                root = flatten(root);
            }
            else
            {
                root->next = nextnext;
                
                root = flatten(root);
            }
        }
    }
    else
    {
        return root;
    }
    return root; 
}

// Node *flatten(Node *root)
// {
//     struct Node *tempnext;
//     struct Node *orphan;
//     struct Node *temporphan;
//     struct Node *troot = root;
//     struct Node *temptempnext;
//     struct Node *cur;
//     struct Node *top;
//     int merged = 0;
//     int c = 0;

//     root = troot;
//     tempnext = root->next;
//     printL(root);
//     while (tempnext != NULL)
//     {
//         if (tempnext->data < root->data)
//         {
//             struct Node *xroot = troot;
//             if (xroot->data > tempnext->data)
//             {
//                 while (tempnext->bottom->data < xroot->data)
//                 {
//                     tempnext = tempnext->bottom;
//                 }
//                 struct Node *keepbottom = tempnext->bottom;
//                 tempnext->bottom = xroot;
//                 root->next = keepbottom;
//                 keepbottom->next = tempnext->next;
//                 tempnext = keepbottom;
//             }
//             else
//             {
//                 while (xroot->bottom->data > tempnext->data)
//                 {
//                     xroot = xroot->bottom;
//                 }
//                 struct Node *keepbottom = xroot->bottom;
//                 xroot->bottom = tempnext;
//                 struct Node *keepnext = tempnext->next;
//                 xroot->next = tempnext->bottom;
//                 tempnext->bottom->next = keepnext;
//                 root = xroot;
//                 tempnext=root->next;
//             }
//         }
//         while (merged == 0)
//         {
//             if (root->bottom == NULL)
//             {
//                 root->bottom = tempnext;
//                 merged = 1;
//             }
//             else if (root->bottom->data < tempnext->data)
//             {
//                 root = root->bottom;
//             }
//             else
//             {
//                 orphan = root->bottom;
//                 root->bottom = tempnext;
//                 while (orphan != NULL)
//                 {
//                     if (root->bottom == NULL)
//                     {
//                         root->bottom = orphan;
//                         break;
//                     }
//                     else if (root->bottom->data > orphan->data)
//                     {
//                         // switch orphans
//                         temporphan = root->bottom;
//                         root->bottom = orphan;
//                         orphan = temporphan;
//                         root = root->bottom;
//                     }
//                     else
//                     {
//                         root = root->bottom;
//                     }
//                 }
//                 merged = 1;
//             }
//         }
//         merged = 0;
//         root = tempnext;
//         tempnext = root->next;
//     }
//     return troot;
// }

int main(void)
{
    int n = 36;
    int bigarr[] = {163, 560, 153, 163, 166, 170, 187, 237, 290, 305, 351, 374, 463, 560, 577, 652, 771, 797, 836, 927, 978, 163, 187, 374, 463,
                    560, 577, 771, 836, 927, 978, 163, 187, 237, 374, 463, 560, 577, 652, 771, 836, 927, 978, 163, 170, 187, 237, 290, 351, 374,
                    463, 560, 577, 652, 771, 797, 836, 927, 978, 163, 187, 237, 374, 463, 560, 577, 652, 771, 836, 927, 978, 153, 163, 170, 187,
                    237, 290, 351, 374, 463, 560, 577, 652, 771, 797, 836, 927, 978, 163, 187, 237, 374, 463, 560, 577, 652, 771, 836, 927, 978,
                    153, 163, 166, 170, 187, 237, 290, 305, 351, 374, 463, 560, 563, 577, 652, 771, 797, 836, 927, 978, 163, 187, 463, 560, 577,
                    771, 836, 927, 163, 187, 237, 374, 463, 560, 577, 652, 771, 836, 927, 978, 153, 163, 166, 170, 187, 237, 290, 305, 351, 374,
                    463, 560, 577, 652, 771, 797, 836, 927, 978, 163, 187, 560, 163, 187, 374, 463, 560, 577, 652, 771, 836, 927, 978, 163, 187,
                    560, 577, 771, 836, 163, 187, 237, 290, 374, 463, 560, 577, 652, 771, 836, 927, 978, 163, 187, 560, 577, 771, 836, 927, 163,
                    187, 237, 290, 374, 463, 560, 577, 652, 771, 836, 927, 978, 163, 187, 237, 290, 351, 374, 463, 560, 577, 652, 771, 797, 836,
                    927, 978, 163, 170, 187, 237, 290, 351, 374, 463, 560, 577, 652, 771, 797, 836, 927, 978, 153, 163, 166, 170, 187, 237, 290,
                    351, 374, 463, 560, 577, 652, 771, 797, 836, 927, 978, 153, 163, 166, 170, 187, 237, 290, 351, 374, 463, 560, 577, 652, 771,
                    797, 836, 927, 978, 163, 187, 237, 290, 374, 463, 560, 577, 652, 771, 836, 927, 978, 153, 163, 166, 170, 187, 237, 290, 305,
                    351, 374, 463, 560, 563, 577, 652, 771, 797, 836, 927, 978, 163, 187, 237, 290, 374, 463, 560, 577, 652, 771, 797, 836, 927,
                    978, 163, 187, 237, 290, 351, 374, 463, 560, 577, 652, 771, 797, 836, 927, 978, 163, 187, 463, 560, 577, 771, 836, 927, 978,
                    153, 163, 166, 170, 187, 237, 290, 351, 374, 463, 560, 577, 652, 771, 797, 836, 927, 978, 153, 163, 166, 170, 187, 237, 290,
                    305, 351, 374, 463, 560, 563, 577, 652, 771, 797, 836, 927, 978, 163, 187, 237, 290, 374, 463, 560, 577, 652, 771, 836, 927,
                    978, 163, 187, 237, 374, 463, 560, 577, 652, 771, 836, 927, 978, 560, 163, 187, 560, 836, 163, 560, 163, 187, 560, 836, 163,
                    187, 374, 463, 560, 577, 652, 771, 836, 927, 978};
    int arr[] = {2, 19, 10, 12, 16, 12, 17, 12, 20, 8, 12, 19, 3, 11, 6, 13, 7, 13, 15, 16, 18, 18, 13, 20, 14, 15, 9, 18, 20, 13, 12, 1, 4, 2, 4, 11};
    int N = 425;
    // int n = 5;
    // int bigarr[] = {163, 560, 153, 163, 163, 927, 153, 420, 163, 927};
    // int arr[] = {2, 2, 2, 2, 2};
    // int N = 10;
    int c = 0;
    struct Node *root = new Node(bigarr[0]);
    struct Node *head = root;
    struct Node *resettotop = root;
    for (int i = 0; i < n; ++i)
    {
        for (int j = 0; j < arr[i] - 1; ++j)
        {
            ++c;
            struct Node *newnode = new Node(bigarr[c]);
            root->bottom = newnode;
            root = root->bottom;
        }
        ++c;
        if (c < N - 1)
        {
            struct Node *newnode = new Node(bigarr[c]);
            root = resettotop;
            root->next = newnode;
            root = root->next;
            resettotop = root;
        }
    }
    printL(head);
    head = flatten(head);
    printList(head);
    return 0;
}