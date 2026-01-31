const serviceFlow = `
    flowchart LR

    Client <--> STAGE
    
    subgraph AWS
    subgraph global

        STAGE{prod}

        PREFLIGHT[preflight]
        
        STAGE --> PREFLIGHT
        PREFLIGHT --> STAGE

        STAGE <--> LIST & PHRASES & QUERY & SYNC

        LIST[list]
        PHRASES[phrases]
        QUERY[query]
        SYNC[sync]

        PREFLIGHT ~~~ LIST & PHRASES & QUERY & SYNC

        LIST <-- GET: / --> BUCKET
        PHRASES <-- POST: / --> OBJECT
        QUERY <-- POST: / --> KB_LAMBDA
        SYNC <-- PATCH: / --> SYNC_LAMBDA

        subgraph auth
            subgraph region_SOURCE
                subgraph bucket
                    BUCKET[S3 Bucket]
                    subgraph objects
                        OBJECT[Phrases Object]
                    end
                end
            end

            subgraph region_KB
                KB_LAMBDA[knowledge base lambda]
                SYNC_LAMBDA[sync lambda]
            end
        end
        end
    end
`

export default serviceFlow
