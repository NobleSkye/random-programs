package main

import (
	"fmt"
	"math/rand"
	"strings"
	"time"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/widget"
)

// Translator represents the main application structure
type Translator struct {
	alphabet map[rune]string
	reverse  map[string]rune
	window   fyne.Window
}

// alphabetData contains the SGA alphabet mapping
var alphabetData = map[rune]string{
	'a': "ᔑ", 'b': "ʖ", 'c': "ᓵ", 'd': "↸", 'e': "ᒷ",
	'f': "⎓", 'g': "⊣", 'h': "⍑", 'i': "╎", 'j': "⋮",
	'k': "ꖌ", 'l': "ꖎ", 'm': "ᒲ", 'n': "リ", 'o': "𝙹",
	'p': "!¡", 'q': "ᑑ", 'r': "∷", 's': "ᓭ", 't': "ℸ ̣",
	'u': "⚍", 'v': "⍊", 'w': "∴", 'x': "̇/", 'y': "||",
	'z': "⨅",
}

// NewTranslator creates and initializes a new Translator instance
func NewTranslator(window fyne.Window) *Translator {
	t := &Translator{
		alphabet: alphabetData,
		reverse:  make(map[string]rune),
		window:   window,
	}

	// Initialize reverse mapping
	for k, v := range t.alphabet {
		t.reverse[v] = k
	}

	rand.Seed(time.Now().UnixNano())
	return t
}

// translateToSGA converts English text to SGA symbols
func (t *Translator) translateToSGA(text string) string {
	var translated strings.Builder
	for _, char := range strings.ToLower(text) {
		if sgaChar, ok := t.alphabet[char]; ok {
			translated.WriteString(sgaChar)
		} else if char == ' ' {
			translated.WriteRune(' ')
		} else {
			translated.WriteRune(char)
		}
	}
	return translated.String()
}

// getMainContent returns the main translator interface
func (t *Translator) getMainContent() *fyne.Container {
	input := widget.NewEntry()
	input.SetPlaceHolder("Enter text to translate")
	output := widget.NewLabel("")
	output.Wrapping = fyne.TextWrapWord

	translateButton := widget.NewButton("Translate", func() {
		translated := t.translateToSGA(input.Text)
		output.SetText(translated)
	})

	copyButton := widget.NewButton("Copy Translation", func() {
		t.window.Clipboard().SetContent(output.Text)
		dialog.ShowInformation("Success", "Text copied to clipboard!", t.window)
	})

	quizButton := widget.NewButton("Take Quiz", func() {
		t.showQuiz()
	})

	creditsButton := widget.NewButton("Credits", func() {
		dialog.ShowInformation("Credits", "Made by NobleSkye using Golang", t.window)
	})

	exitButton := widget.NewButton("Exit", func() {
		t.window.Close()
	})

	return container.NewVBox(
		widget.NewLabel("Enter text to translate:"),
		input,
		translateButton,
		widget.NewLabel("Translation:"),
		output,
		copyButton,
		quizButton,
		creditsButton,
		exitButton,
	)
}

// showQuiz displays the quiz interface
func (t *Translator) showQuiz() {
	score := 0
	totalQuestions := 10
	currentQuestion := 0

	// Create a slice of letters for randomization
	letters := make([]rune, 0, len(t.alphabet))
	for k := range t.alphabet {
		letters = append(letters, k)
	}
	rand.Shuffle(len(letters), func(i, j int) {
		letters[i], letters[j] = letters[j], letters[i]
	})

	// Create quiz container
	quizContent := container.NewVBox()

	// Question components
	questionLabel := widget.NewLabel("")
	answerEntry := widget.NewEntry()
	submitButton := widget.NewButton("Submit Answer", nil)
	returnButton := widget.NewButton("Return to Translator", func() {
		t.window.SetContent(t.getMainContent())
	})

	// Initialize score label
	scoreLabel := widget.NewLabel(fmt.Sprintf("Score: %d/%d", score, currentQuestion))

	// Function to show next question or end quiz
	showNextQuestion := func() {
		if currentQuestion < totalQuestions {
			letter := letters[currentQuestion]
			sgaSymbol := t.alphabet[letter]
			questionLabel.SetText(fmt.Sprintf("Question %d: What is the English letter for '%s'?", currentQuestion+1, sgaSymbol))
			answerEntry.SetText("")
			answerEntry.Enable()
			submitButton.Enable()
		} else {
			finalMessage := fmt.Sprintf("Quiz complete! Final score: %d/%d", score, totalQuestions)
			dialog.ShowInformation("Quiz Complete", finalMessage, t.window)
			t.window.SetContent(t.getMainContent())
		}
	}

	// Set up submit button action
	submitButton.OnTapped = func() {
		if currentQuestion < totalQuestions {
			answer := strings.ToLower(strings.TrimSpace(answerEntry.Text))
			letter := letters[currentQuestion]

			if answer == string(letter) {
				score++
				dialog.ShowInformation("Correct!", "Good job!", t.window)
			} else {
				dialog.ShowInformation("Incorrect", fmt.Sprintf("The correct answer was '%c'", letter), t.window)
			}

			currentQuestion++
			scoreLabel.SetText(fmt.Sprintf("Score: %d/%d", score, currentQuestion))
			showNextQuestion()
		}
	}

	// Build quiz interface
	quizContent.Add(widget.NewLabel("Standard Galactic Alphabet Quiz"))
	quizContent.Add(scoreLabel)
	quizContent.Add(questionLabel)
	quizContent.Add(answerEntry)
	quizContent.Add(submitButton)
	quizContent.Add(returnButton)

	// Show first question
	showNextQuestion()

	// Set quiz content
	t.window.SetContent(quizContent)
}

func main() {
	a := app.New()
	w := a.NewWindow("SGA Translator")

	translator := NewTranslator(w)

	w.SetContent(translator.getMainContent())
	w.Resize(fyne.NewSize(300, 400))
	w.ShowAndRun()
}
