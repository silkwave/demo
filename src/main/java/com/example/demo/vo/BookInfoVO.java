package com.example.demo.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
 
@Getter
@Setter
@ToString
public class BookInfoVO {

   private int book_key;
   
   private String book_reg_no;
   
   private String book_title;
   
   private String book_author;
   
   private String book_publisher;
   
}
