package com.reconnect.mindhealth.common.dto;

import org.springframework.http.HttpStatus;

public class ApiResponse<T> {
    private String message;
    private T data;
    private int status;

    public ApiResponse(String message, T data, int status) {
        this.message = message;
        this.data = data;
        this.status = status;
    }

    public ApiResponse(int status, String message) {
        this.status = status;
        this.message = message;
    }

    public static <T> ApiResponse<T> success(String message,T data){
        return new ApiResponse<>(message, data, HttpStatus.OK.value());
    }

    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(message, null, HttpStatus.INTERNAL_SERVER_ERROR.value());
    }

    public static <T> ApiResponse<T> custom(String message, T data, HttpStatus status) {
        return new ApiResponse<>(message, data, status.value());
    }

    public ApiResponse() {
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}
