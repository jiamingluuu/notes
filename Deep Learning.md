GPT (Generative Pre-trained Transformer) model takes receives an chunks of input data (maybe texts, voice, video, etc.) and outputs a probability distribution of the possible upcoming data. To generate a whole article, we can simply gives a tiny chunk of text as an initializer, and iteratively repeats process.

Text is broken into tokens, tokens are then associated to vectors (which is called vector embedding).

## Vector Embedding