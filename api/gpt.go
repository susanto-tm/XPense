package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/sashabaranov/go-openai"
)

var client *openai.Client

type DocumentContext struct {
	context string
}

func (document DocumentContext) SystemMessage() string {
	return `You are a receipt parser. You will be given a receipt. Based on the context, return the name of the restaurant, categorize the restaurant, the items with its name and price, and the total price. Format your answer according to the example. 
Example context: STARBUCKS Store #7822 232 West College Avenue State College, PA (814) 235-481 CHK 708952 04/07/2023 05:18 PM XXX6031 Drawer: 1 Reg: 1 Cafe To Go Order Cookie Madelin 3Pk 2.45 Subtotal Discounts Tax 6% Total Change Due 2.45 0.00 0.15 2.60 0.00 Payments Sux Card XXXXXXXXXXXX6466 • - - Check Closed - - 04/07/2023 05:18 PM SBUX Card ×6466 New Balance: Card is registered. 2.60 0.94 Join our loyalty program Starbucks Rewards® Sign up for promotional emails Visit Starbucks.com/rewards Or download our app At participating stores Some restrictions apply. 
Example answer: {"name": "STARBUCKS", "category": "Cafe", "total": 2.6, "items": [{"name": "Cookie Madelin 3Pk", "quantity": 1, "price": 2.45}]}`
}

func (document DocumentContext) UserMessage() string {
	return fmt.Sprintf("Context: %s", document.context)
}

func (document DocumentContext) GptReceiptCompletion() (receipt Receipt, err error) {
	resp, chatError := client.CreateChatCompletion(
		context.Background(),
		openai.ChatCompletionRequest{
			Model:       openai.GPT3Dot5Turbo,
			Temperature: 0,
			MaxTokens:   500,
			Messages: []openai.ChatCompletionMessage{
				{
					Role:    openai.ChatMessageRoleSystem,
					Content: document.SystemMessage(),
				},
				{
					Role:    openai.ChatMessageRoleUser,
					Content: document.UserMessage(),
				},
			},
		},
	)

	if err != nil {
		err = chatError
	} else if len(resp.Choices) > 0 {
		if jsonError := json.Unmarshal([]byte(resp.Choices[0].Message.Content), &receipt); jsonError != nil {
			err = jsonError
			return
		}
		err = nil
	} else {
		receipt = Receipt{Name: "", Category: "", Items: []ReceiptItem{}}
		err = chatError
	}
	return
}
