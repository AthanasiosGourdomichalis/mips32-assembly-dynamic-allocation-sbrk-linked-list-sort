# **`MIPS32`** Dynamic Linked List Manager
![MIPS Assembly](https://img.shields.io/badge/Language-MIPS%20Assembly-blue)
![Simulator](https://img.shields.io/badge/Simulator-SPIM-lightgrey)

> This repository contains a **`MIPS32 assembly`** program that creates and manages a **dynamic linked list** of integers. **Node insertion** and **deletion** are implemented in such a way that the **list remains sorted** in **ascending order** at all times. The program handles **dynamic memory allocation** directly via the `sbrk` system call (`syscall 9`).

## Features
*   **Dynamic Memory Allocation:** Nodes are allocated at runtime using `syscall 9` (`sbrk`), without relying on static arrays.
*   **Sorted Insertion:** New integers are automatically placed in their correct ascending position.
*   **Node Deletion:** Removes specified values while maintaining the list's sorted order.
*   **Interactive UI:** A command-line menu allows users to insert, delete, print the list, or exit the program.
---

## Modular Structure
The program is built using a strict procedural approach with the following subroutines:
*   `CreateNode`: Allocates 8 bytes of memory for a new node and initializes its data and pointer.
*   `InsertNode`: Finds the correct position and links the new node into the sorted list.
*   `DeleteNode`: Searches for a target value and safely removes its node from the list.
*   `PrintList`: Iterates through the list and displays all elements sequentially.
---

## How to Run
1. Download and install the [SPIM Simulator](http://spimsimulator.sourceforge.net/) (QtSpim or PCSpim).
2. Clone this repository or download the `linked_list_solution.s`.
3. Open the `.s` file in your SPIM simulator.
4. Run the program and interact with the menu through the console.
---

## 📄 Documentation
For a detailed description of the assignment requirements, constraints, modular structure rules, and a sample execution, please refer to the assignment document:
[assignment.pdf](./assignment.pdf)

---

# 👤 Author
## **Athanasios Gourdomichalis** - [GitHub Profile](https://github.com/AthanasiosGourdomichalis)

---
