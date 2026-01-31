const examples = require("./queryData.js")
const { story, chapter, paragraph } = examples

const QUERY_URL = "https://mc4mepqu58.execute-api.us-east-1.amazonaws.com/prod/query"
const TO_PARAGRAPHS_PATH = "path/to/script.py"

const markStoryRequest = async (story) => {
    return await fetch(QUERY_URL, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        },
        mode: "cors",
        body: story
    })
}

function toParagraphs(story) {
    const paragraphs = []
    const spawn = require("child_process").spawn;
    const pythonProcess = spawn('python', [TO_PARAGRAPHS_PATH, story]);

//for script
//print(dataToSendBack)
//sys.stdout.flush()

    pythonProcess.stdout.on('data', (data) => {
        paragraphs = data
    });

    return paragraphs
}

describe("paragraph", () => {
    const text = paragraph
    test("only { }", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/g, "")

        expect(demarked).toMatch(text)
    })

    test("max 1 mark per paragraph", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/, "")

        expect(demarked).toMatch(text)
    })
})

describe("chapter", () => {
    const text = chapter
    test("only { }", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/g, "")

        expect(demarked).toMatch(text)
    })

    test("max 1 mark per paragraph", async () => {
        const paragraphArr = toParagraphs(text)

        const eoParagraph = ""
        const paraText = paragraphArr.join(eoParagraph)

        const response = await markStoryRequest(paraText)
        const marked = await response.text()

        const paraMarked = marked.split(eoParagraph)

        paraMarked.forEach((para, i) => {
            const demarked = para.replace(/\{|\}/, "")
            expect(demarked).toMatch(paragraphArr[i])
        })
    })
})

describe("story", () => {
    const text = story
    test("only { }", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/g, "")

        expect(demarked).toMatch(text)
    })

    test("max 1 mark per paragraph", async () => {
        const paragraphArr = toParagraphs(text)

        const eoParagraph = ""
        const paraText = paragraphArr.join(eoParagraph)

        const response = await markStoryRequest(paraText)
        const marked = await response.text()

        const paraMarked = marked.split(eoParagraph)

        paraMarked.forEach((para, i) => {
            const demarked = para.replace(/\{|\}/, "")
            expect(demarked).toMatch(paragraphArr[i])
        })
    })
})
