package br.com.wagner.service;

import org.springframework.stereotype.Service;

@Service
public class ChatService {

    public String getWelcomeMessage() {
        return "Welcome to the Chat Service!";
    }

}
