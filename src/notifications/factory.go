package notifications

import (
	"errors"
	"os"
)

type Notifier interface {
	Notify(text string, subject string)
}

func NotifierFactory() (Notifier, error) {
	notifier := os.Getenv("APP_NOTIFIER")
	switch notifier {
	case "http":
		return NewHttpNotifier(), nil
	case "smtp":
		return NewSmtpNotifier(), nil
	default:
		return nil, errors.New("Unknown notification provider.")
	}
}
