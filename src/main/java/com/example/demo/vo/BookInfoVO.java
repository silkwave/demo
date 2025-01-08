package com.example.demo.vo;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
 
@Getter
@Setter
@ToString
public class BookInfoVO {

   @JsonProperty(value="book_key")
   private int book_key;
   
   @JsonProperty(value="book_reg_no")
   private String book_reg_no;
   
   @JsonProperty(value="book_title")
   private String book_title;
   
   @JsonProperty(value="book_author")
   private String book_author;
   
   @JsonProperty(value="book_publisher")
   private String book_publisher;
   
}
