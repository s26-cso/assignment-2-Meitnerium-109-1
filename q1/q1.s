.globl make_node
.globl insert
.globl get
.globl getAtMost

.text

# struct Node* make_node(int val);
# a0: val
make_node:
    # prologue
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    
    # save val in s0
    mv s0, a0
    
    # call malloc(24)
    li a0, 24
    call malloc
    
    # if a0 == 0, go to make_node_end
    beqz a0, make_node_end
    
    # store val at offset 0
    sw s0, 0(a0)
    
    # store NULL (0) at left (8) and right (16)
    sd zero, 8(a0)
    sd zero, 16(a0)
    
make_node_end:
    # epilogue
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# struct Node* insert(struct Node* root, int val);
# a0: root, a1: val
insert:
    # Base case: if root is NULL, return make_node(val)
    bnez a0, insert_compare
    mv a0, a1
    tail make_node

insert_compare:
    # prologue
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)   # s0 = root
    sd s1, 8(sp)    # s1 = val

    mv s0, a0
    mv s1, a1

    # load root->val
    lw t0, 0(s0)

    # if val == root->val, do nothing, return root
    beq s1, t0, insert_end

    # if val < root->val, insert(root->left, val)
    blt s1, t0, insert_left

    # else (val > root->val), insert(root->right, val)
    j insert_right

insert_left:
    ld a0, 8(s0)
    mv a1, s1
    call insert
    sd a0, 8(s0)
    j insert_end

insert_right:
    ld a0, 16(s0)
    mv a1, s1
    call insert
    sd a0, 16(s0)
    j insert_end

insert_end:
    mv a0, s0
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

# struct Node* get(struct Node* root, int val);
# a0: root, a1: val
get:
    # if root == NULL, return NULL
    beqz a0, get_end
    
    lw t0, 0(a0)
    
    # if val == root->val, return root
    beq a1, t0, get_end
    
    # if val < root->val, tail call get(root->left, val)
    blt a1, t0, get_left
    
    # else tail call get(root->right, val)
    ld a0, 16(a0)
    tail get
    
get_left:
    ld a0, 8(a0)
    tail get

get_end:
    ret

# int getAtMost(int val, struct Node* root);
# a0: val, a1: root
getAtMost:
    # if root == NULL, return -1
    li t0, -1
    bnez a1, getAtMost_check
    mv a0, t0
    ret

getAtMost_check:
    lw t0, 0(a1)
    
    # if root->val > val, answer is strictly in the left subtree
    bgt t0, a0, getAtMost_left
    
    # else root->val <= val
    # we need to check right subtree for a better answer
    addi sp, sp, -16
    sd ra, 8(sp)
    sd t0, 0(sp) # save root->val
    
    # call getAtMost(val, root->right)
    # a0 is already val
    ld a1, 16(a1)
    call getAtMost
    
    # result is in a0. if it's != -1, it means we found something
    li t1, -1
    bne a0, t1, getAtMost_end
    
    # else, return root->val (which we saved)
    ld a0, 0(sp)

getAtMost_end:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

getAtMost_left:
    ld a1, 8(a1)
    tail getAtMost
