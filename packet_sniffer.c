#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/if_ether.h>
#include <netinet/ip.h>

#define BUFFER_SIZE 65536

int main() {
    int raw_socket;
    unsigned char *buffer = (unsigned char *)malloc(BUFFER_SIZE);
    if (buffer == NULL) {
        fprintf(stderr, "Memory Allocation Failed in Heap.\n");
        return 1;
    }

    raw_socket = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if (raw_socket < 0) {
        fprintf(stderr, "Socket Initialization Failed. Ensure Root Privileges.\n");
        free(buffer);
        return 1;
    }

    while (1) {
        ssize_t packet_size = recvfrom(raw_socket, buffer, BUFFER_SIZE, 0, NULL, NULL);
        if (packet_size < 0) {
            continue;
        }

        fwrite(&packet_size, sizeof(ssize_t), 1, stdout);
        fwrite(buffer, 1, packet_size, stdout);
        fflush(stdout);
    }

    close(raw_socket);
    free(buffer);
    return 0;
}
