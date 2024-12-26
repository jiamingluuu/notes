Retrieval-augmented generation (RAG) is aims to mitigate 
- lack of long-tail knowledge, risks of leaking private training data in the scope of AIGC.
- hallucination, outdated knowledge, and non-transparent, untraceable reasoning processes.

The RAG process mainly comprises the following steps:
1. the retriever initially receives the input query and searches for relevant information
2. the original query and the retrieval results are fed into the generator through a specific augmentation methodology
3. the generator produces the desired outcomes

> A retriever is aimed to encodes each query into a specific representation; and then construct a index to organize the data source for efficient search.
# Categories of RAG Foundation Paradigms
## Query-based RAG
![[query-based-rag.png]]
The user's query with insights from retrieved information are fed directly into the initial stage of the generator's input.

![[realm-framework.png]]
REALM is one of the well-known for text generation, our objective here is to learn the probability distribution of $p(y|x)$ of all possible output $y$ with some given input $x$.

The roadmap is to firstly use the probability distribution $p(z|x)$ of **knowledge retriever** to retrieve possibly helpful documents $z$ from a knowledge corpus $\mathcal{Z}$, then combines both the retrieved document and the input to obtain the overall likelihood $p(y|z, x)$. The condition distribution of $y$ is simply given by marginalization:
$$p(y|x)= \sum_{z\in \mathcal{Z}}p(y|z, x)p(z|x)$$
where
$$\begin{aligned}
p(z|x)&=\frac{\exp{f(x, z)}}{\sum_{z'}\exp{f(x, z')}}\\
f(x, z)&= \texttt{Embed}(x)^T\texttt{Embed}(z)
\end{aligned}$$
>Computing the marginalization is computation intensive, we can approximate this by instead summing over the top $k$ documents with highest probability under $p(z|x)$.

Then we use a **knowledge-augmented encoder** $p(y|z, x)$ to (i) joint $x$ and $z$ into a single sequence that we feed into a Transformer (distinct from the one used in the retriever).
$$\begin{aligned}
p(y|z, x) &= \prod^{J_x}_{j=1}p(y_j | z, x)\\
p(y_j | z, x) &\propto \exp{(w_j^T\texttt{BERT}_{\texttt{MASK}(j)}(\texttt{join}_\texttt{BERT}(x, z_{body})))}
\end{aligned}$$

## Latent Representation-based RAG
![[latent-representation-based-rag.png]]
Retrieved objects are incorporated into generative models as latent representations.

FiD (Fusion-in-Decoder): A open domain QA model (the task of answering general domain questions, in which the evidence is not given as input to the system).
![[fid-architencture.png]]
We retrieve passage (a small chunk of words) (using BM25 and DPR), concatenates the question and the passage, and encode them separately, then concats the encoded results and pass to the decoder.

## Logit-based RAG
![[logit-based-rag.png]]
Generative models integrate retrieval information through logits during the decoding process. Typically, the logits are combined through simple summation or models to compute the probabilities for step-wise generation

![[knn-lm.png]]
KNN-LM: A datastore is constructed with an entry for each training set token, and an encoding of its leftward context. For inference, a test context is encoded, and the k most similar training contexts are retrieved from the datastore, along with the corresponding targets. A distribution over targets is computed based on the distance of the corresponding context from the test context. This distribution is then interpolated with the original model’s output distribution.

## Speculative RAG
Seeks opportunities to use retrieval instead of pure generation.
![[speculative-rag.png]]

![[retrieval-is-accurate-generation.png]]
TODO: Figure out how does this model work

# RAG Enhancements
![[rag-enhancements.png]]
TODO: Look into hybrid retrieval, does this going to help with SIMLE project?

# Applications
![[rag-applications.png]]
## RAG for knowledge
TODO: 