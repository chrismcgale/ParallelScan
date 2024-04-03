
// Idea behind radix sort is to iterate over each digit (left to right) and order
__host__ radix_sort(unsigned int* input, unsigned int* output, unisgned int n, unsigned int sigFigs) {

    for (int i = 0; i < sigFigs; i++) {

        unsigned int bits[n];

        unsigned int key;

        cudaMalloc((void**)&input, sizeof(unsigned int));
        cudaMalloc((void**)&output, sizeof(unsigned int));
        cudaMalloc((void**)&bits, sizeof(unsigned int));
        cudaMalloc((void**)&&key, sizeof(unsigned int));

        radix_sort_iter_get_bits<<<n / SECTION_SIZE, SECTION_SIZE>>>(input, output, bits, &key, n, i);

        // exclusive scan on significant bits
        hierchical_scan(bits, bits, n, false);

        radix_sort_iter_assign<<<n / SECTION_SIZE, SECTION_SIZE>>>(bits, output, bits, key, n);

        // Repeat with output the new input
        input = output;

        cudaFree(input);
        cudaFree(output);
        cudaFree(bits);
        cudaFree(key);
    }

}


__global__ void radix_sort_iter_get_bits(unsigned int* input, unsigned int* output, unsigned int* bits, unsigned int* key, unisgned int n, unsigned int iter) {
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    unsigned int  bit;
    if (i < n) {
        *key = input[i];
        bit = (key >> iter) & 1;
        bits[i] = bit;
    }
}

__global__ void radix_sort_iter_assign(unsigned int* input, unsigned int* output, unsigned int* bits, unsigned int key, unisgned int n) {
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    if (i < n) {
        unsigned int numOnesBefore = bits[i];
        unsigned int numOnesTotal = bits[n];
        unsigned int dst = (bit == 0) ? (i - numOnesBefore) : (n - numOnesBefore - numOnesBefore);
        
        output[dst] = key;
    }
}