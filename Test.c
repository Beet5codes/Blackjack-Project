#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern int dealPlayer(int playerScore, int* deck);
extern int dealDealer(int dealerScore, int* deck);
extern char getChoice();
extern int hit(int playerScore, int* deck, int aceFlag);
extern char getGame();

#define NUM_CARDS 52

//Function to swap two elements in an array
void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// Function to shuffle the deck of cards
void shuffleDeck(int* deck, int numCards) {
    srand(time(NULL));  // Initialize random seed

    for (int i = numCards - 1; i > 0; --i) {
        int j = rand() % (i + 1);  // Generate a random index from 0 to i

        // Swap the current card with a random card
        swap(&deck[i], &deck[j]);
    }
}

void main()
{
	// Create a deck array size 52    
	int deck[NUM_CARDS];
	char game = 'y';
	int playerScore = 0;
	int dealerScore = 0;
	char hitOrNo;
	//tells hit function whether to look at the player or dealers aces
	int aceFlag = 0; // 0 = players aces and 1 = dealers aces
	for (int i = 0; i < NUM_CARDS; i++) {
    	deck[i] = i + 1;
	}
	while (game == 'y') {
		shuffleDeck(deck, NUM_CARDS);
		printf("Player Hand\n");
		playerScore = dealPlayer(playerScore, deck);
		printf("Player Score: %d\n", playerScore);
		printf("Dealer Hand\n");
		dealerScore = dealDealer(playerScore, deck);
		
		hitOrNo = getChoice();
		while (hitOrNo != 's' && playerScore < 21) {
			playerScore = hit(playerScore, deck, aceFlag);
			printf("Player Score: %d\n", playerScore);
			hitOrNo = getChoice();
		}
		
		aceFlag = 1;
		
		while (dealerScore < 16 && playerScore < 21) {
			dealerScore = hit(dealerScore, deck, aceFlag);
			printf("Dealer Score: %d\n", dealerScore);
		}
		
		if (playerScore == 21) {
			printf("Player got a Blackjack and won!\n");
		} else if (playerScore > 21) {
			printf("Player went over 21 and lost!\n");
		} else if (dealerScore > 21) {
			printf("Deal went over 21 Player won!\n");
		} else if (playerScore > dealerScore) {
			printf("Player got a higher score than Dealer and won!\n");
		} else {
			printf("Player got a lower score than Dealer and lost!\n");
		}
		
		game = getGame();
	}

/*
	for (int i = 0; i < NUM_CARDS; i++) {
		printf("%d: ", i);
    	printf("%d ", deck[i]);
	}
	printf("\n");*/
}

