;****************************************
; CALCULO DE AREA DE CIRCULO
;***************************************************************
; imprime un mensaje dado

imprime MACRO mensaje
    MOV DX,offset mensaje
    MOV AH,09h  ; Funcion que imprime en pantalla
    INT 21h ; ejecuta la funcion
ENDM               
       
;***************************************************************

; Lee un caracter por teclado  (lo guarda en ah}

leeCaracter MACRO 
    mov     ah, 01h
    int     21h

ENDM        


;*******************************************************************        
;recibe un numero multidigito por teclado y lo guarda en cx 
;va recibiendo digito por digito y multiplicando lo que lleva por 10
;sumandolo con el nuevo ingresado
escaneaNumero MACRO
LOCAL siguienteDigito,fueraDeRango,parar
    
        xor     cx, cx

siguienteDigito:

        leeCaracter



        ; reviso si se si ingreso la tecla ENTER
        cmp     al, cr
        je      parar

        ; multiplica cx por 10
        push    ax
        mov     ax, cx
        mul     diez                     ; dx:ax = ax*10
        mov     cx, ax
        pop     ax

        ; revisa si el numero es muy grande 
        ;deberia ser 16 bits
        cmp     dx, 0
        jne     fueraDeRango

        ;ascii->numero
        sub     al, 30h

        ;suma al en cx
        xor     ah, ah
        add     cx, ax
        jc      fueraDeRango    ; salta si el numero es muy grande

        jmp     siguienteDigito



fueraDeRango:
        imprime error

parar:
  
        
ENDM


;***************************************************************   
;imprime un caracter
escribeCaracter MACRO
        mov     ah, 02h
        int     21h
ENDM
;***************************************************************
;imprime un numero multidigito entero que se encuentre en ax  
;inicializa en bx un divisor y va extrayendo los digitos mas a la izquierda
;con las divisiones hasta llegar al ultimo            
imprimeNumero      MACRO   
LOCAL comienzaImprimir,calc,siguiente,terminar
        push    bx
        push    cx
        push    dx

        ; bandera que previene imprimir ceros antes del numero
        mov     cx, 1

        mov     bx, 10000       ; 2710h - divisor

        ; revisa si ax es cero, si es entonces termina
        cmp     ax, 0
        jz      terminar

comienzaImprimir:

        ; revisa el divisor (si es cero entonces termina)
        cmp     bx,0
        jz      terminar

        ; evita imprimir ceros antes del numero
        cmp     cx, 0
        je      calc
        ;si ax<bx entonces resultado del div va a ser cero
        cmp     ax, bx
        jb      siguiente
calc:
        xor     cx, cx  ; reseteo bandera

        xor     dx, dx
        div     bx      ; ax = dx:ax / bx   (dx=residuo).
 
        ;imprime el ultimo digito ah es siempre 0 entonces es ignorado
        push    dx
        mov     dl, al
        add     dl, 30h    ; numero->ascii
        escribeCaracter
        pop     dx

        mov     ax, dx  ;obtiene residuo del last div

siguiente:
        ; calcula bx=bx/10
        push    ax
        xor     dx, dx
        mov     ax, bx
        div     diez     ; ax = dx:ax / 10   (dx=residuo).
        mov     bx, ax
        pop     ax

        jmp     comienzaImprimir

terminar:

        pop     dx
        pop     cx
        pop     bx
        
ENDM

;******************************************************************   
;imprime dx como una fraccion de la division por bx
; dx - residuo
; bx - divisor
; cx - maximo digitos despues del punto
imprimeFraccion  MACRO
LOCAL siguienteFraccion,noSig1,noSig2,termina   
        push    ax
        push    dx
siguienteFraccion:
        ; reviso si todos los digitos estan impresos
        cmp     cx, 0
        jz      termina
        dec     cx      ; decremento el contador de digitos

        ;cuando el residuo es cero no hay necesidad de continuar
        cmp     dx, 0
        je      termina

        mov     ax, dx
        xor     dx, dx
        cmp     ax, 0
        jns     noSig1
        not     dx
noSig1:

        imul    diez             ; dx:ax = ax * 10

        idiv    bx              ; ax = dx:ax / bx   (dx - residuo)

        push    dx              ; guarda residuo
        mov     dx, ax
        cmp     dx, 0
        jns     noSig2
        neg     dx
noSig2:
        add     dl, 30h         ; numero->ascii
            escribeCaracter      ; imprime dl
        pop     dx

        jmp     siguienteFraccion
termina:
        pop     dx
        pop     ax
        
ENDM

;***************************************************************  
;imprime un numero en ax y su fraccion en dx
;tambien usado para imprimir el residuo en bx
; ax - parte entera
; dx - residuo
; bx - el divisor que fue usado para obdiezer todo el residuo del dividendo 
imprimirFlotante     MACRO  
LOCAL listo
        push    cx
        push    dx

        ;imprime la parte entera
        imprimeNumero

        ;si el residuo es 0 entonces no hay parte decimal
        cmp     dx, 0
        je      listo

        push    dx
        ; imprime el punto
        mov     dl, '.'
        escribeCaracter
        pop     dx

        ;imprime los digitos despues del punto
        mov     cx, precision
        imprimeFraccion
listo:
        pop     dx
        pop     cx
        
ENDM     

;***************************************************************
;pide el radio y calcula el area del circulo
areaCirculo MACRO
    imprime mensajeRadio 
    imprime siguienteLinea
    escaneaNumero
    mov ax,cx ;muevo el numero escaneado a ax
    mul ax   ;elevo al cuadrado
    mov bx,PI ;copio el valor de PI en 
    mul bx
    mov bx,100 ;dos decimales
    div bx 
    
    ;protejo los valores en la pila
    push ax 
    push dx
    push bx
    
    imprime siguienteLinea
    imprime mensajeArea
    ;resturo los valores protegidos en la pila
    pop bx
    pop dx
    pop ax
     
    imprimirFlotante 
    imprime m2 
ENDM

;*****************************************************************    
;*****************************************************************   
;pide lados del cuadrado
areaCuadrado MACRO
      imprime mensajeLado
    imprime siguienteLinea
    escaneaNumero
    push cx 
    
    mov ax,cx
    mul cx 
    
    ;protejo los valores en la pila
    push ax 
    
    imprime siguienteLinea 
    imprime mensajeArea
    
    ;resturo los valores protegidos en la pila
    pop ax
     
    imprimeNumero 
    imprime m2 
ENDM       

;*****************************************************************
;pide base y altura y calcula el area del rectangulo
areaRectangulo MACRO
    imprime msgBase 
    imprime siguienteLinea
    escaneaNumero
    push cx 
    
    imprime msgAltura 
    imprime siguienteLinea
    escaneaNumero
    
    mov ax,cx
    pop cx
    mul cx 
    
    ;protejo los valores en la pila
    push ax 
    
    imprime siguienteLinea 
    imprime mensajeArea
    
    ;resturo los valores protegidos en la pila
    pop ax
     
    imprimeNumero 
    imprime m2    
ENDM


;*****************************************************************
;pide base y altura y calcula el area del triangulo
areaTriangulo MACRO
    imprime msgBase 
    imprime siguienteLinea
    escaneaNumero
    push cx 
    
    imprime msgAltura 
    imprime siguienteLinea
    escaneaNumero
    
    mov ax,cx
    pop cx
    mul cx 

    mov bx,2
    div bx 
    
    ;protejo los valores en la pila
    push ax 
    push dx
    push bx
    
    imprime siguienteLinea 
    imprime mensajeArea
    
    ;resturo los valores protegidos en la pila
    pop bx
    pop dx
    pop ax
     
    imprimirFlotante 
    imprime m2
      
ENDM 

;**********************
;MACROS PARA EL CIRCULO
;**********************  

;b = a
asignar macro a, b
    mov ax, [b]
    mov [a], ax    
endm

;a = -a 
negar macro a
    mov ax, [a]
    neg ax
    mov [a], ax    
endm

;a = a+1 
incrementar macro a
    mov ax, [a]
    inc ax
    mov [a], ax    
endm

;a = a-1 
decrementar macro a
    mov ax, [a]
    dec ax
    mov [a], ax    
endm

;a=b?
comparar macro a, b
    mov cx, [a]
    cmp cx, [b]
endm

compara_var_num macro a, b
    mov cx, [a]
    cmp cx, b
endm

;c = a+b
suma macro c, a, b
    mov ax, [a]
    add ax, [b]
    mov [c], ax
endm 

;c = a-b
resta macro c, a, b
    mov ax, [a]
    sub ax, [b]
    mov [c], ax
endm

;d = a+b+c
suma_tres_numeros macro d, a, b, c
    mov ax, [a]
    add ax, [b]
    add ax, [c]
    mov [d], ax
endm 

;d = a-b-c
resta_tres_numeros macro d, a, b, c
    mov ax, [a]
    sub ax, [b]
    sub ax, [c]
    mov [d], ax
endm

pixel macro x, y
    
    mov cx, [x]  ; columna  
    mov dx, [y]  ; fila  
     
    mov al, 11  ; blanco
    mov ah, 0ch ; dibuja el pixel
    int 10h     
endm
;fin macros

;macro para dibujar el circulo
circle macro centerx, centery, radius 
    
       
    
    asignar yy, radius
    
    asignar balance, radius
    
    negar balance
    
    draw_circle_loop:
     
    suma suma_x, centerx, xx
    
    resta resta_x, centerx, xx
    
    suma suma_y, centery, yy
    
    resta resta_y, centery, yy
     
    suma suma_xy, centerx, yy
    
    resta resta_xy, centerx, yy
    
    suma suma_yx, centery, xx
    
    resta resta_yx, centery, xx 

    pixel suma_xy, resta_yx
    
    pixel suma_x, resta_y

    pixel resta_x, resta_y   

    pixel resta_xy, resta_yx 

    pixel resta_xy, suma_yx    

    pixel resta_x, suma_y
        
    pixel suma_x, suma_y    

    pixel suma_xy, suma_yx

    suma_tres_numeros balance, balance, xx, xx
    
    compara_var_num balance, 0
    
    jl balance_negative
    
    balance_positive:
    
    decrementar yy
    
    resta_tres_numeros balance, balance, yy, yy
    
    balance_negative:
    
    incrementar xx
    
    comparar xx, yy
    
    jg end_drawing
    jmp draw_circle_loop
    
    
    end_drawing:
       
endm

;fin macro para dibujar el circulo
     
     
.model small

.data

;VARIABLES PARA LAS AREAS DE LAS FIGURAS
mensajeRadio DB 10,13, "Ingrese el radio del circulo (debe ser menor o igual a 102>$"
siguienteLinea DB 10,13, "$" 
PI equ 314  ;valor de pi 3.14     
contador db 0 ;contador de uso general para ciclos  
radio db 0   
cr              equ     0Dh ;tecla enter
error           db      cr, 0Ah, 'El numero esta fuera de rango!', siguienteLinea
diez             dw      10      ; usado como un multiplicador
precision EQU 2  ; numero de digitos despues del punto   
OP db 0 

;VARIABLES PARA EL DIBUJO DEL CIRCULO

x dw 80 ; center x
y dw 80 ; center y
r dw 25 ; radius  

balance dw 0
    
xx dw 0
    
yy dw 0 
    
suma_x dw 0
    
resta_x dw 0
    
suma_y dw 0
    
resta_y dw 0
   
suma_xy dw 0
   
resta_xy dw 0
   
suma_yx dw 0
   
resta_yx dw 0 



;Mensajes
   msg1 db 10,13,"Ingrese que figura desea escoger$"
   msgOP db 10,13,"1:Cuadrado 2:Rectangulo 3:Triangulo 4:Circulo 5:Salir$" 
   msgP db 10,13,"Funciona$"
   mensajeLado db 10,13, "Ingrese el valor de los lados del cuadrado$"            
   msgBase db 10,13, "Ingrese el valor de la base de la figura$"
   msgAltura db 10,13, "Ingrese el valor de la altura de la figura$"  
   msgRadio db 10,13, "Ingrese el valor del radio$"
   msgError db 10,13, "El valor ingresado no se encuentra dentro de las opciones.Presione ENTER$"
   m2 db " u^2$"   
   msgdib db 10,13, "Presione ENTER para dibujar la figura seleccionada$"   
   mensajeArea db 10,13, "Area = $"
   
.code

MOV AX, @DATA
MOV DS,AX
            
;**************************
;MENU
;**************************                            
                            

 

Menu: 
   call LimpiaPantalla
   call LimpiaPantalla
   ;Muestra mensaje 1
   MOV DX,offset msg1 
   MOV AH,09h  ; Funcion que imprime en pantalla 
   INT 21h ; ejecuta la funcion 
   MOV DX,offset msgOP 
   MOV AH,09h   
   INT 21h  
          
   MOV DX, offset siguienteLinea    
   MOV AH, 09h            
   INT 21h                 
   
   ;Pide por pantalla la opcion
   MOV AH,01h  
   INT 21h    
   
   ;Transforma el valor ascii a decimal
   sub AL, 30h
   MOV OP, AL     
   
    ;wait for keypress
  mov ah,00
  int 16h
   
   ;Compara opcion escogida
   cmp OP, 1d 
   je Cuadrado
   
   cmp OP,2d 
   je Rectangulo
   
   cmp OP,3d          
   je Triangulo 
   
   cmp OP,4d          
   je Circulo
   
   cmp OP, 5d
   je Salida 
   

    
    
   ;
   ;ERROR DE SELECCION
   ;      
                      
                     
   ErrorSeleccion:
       MOV DX,offset msgError
       MOV AH, 09h
       INT 21h
       MOV AH,01h  
       INT 21h  
       
       call LimpiaPantalla 
       jmp menu 
  
  ;
  ;MENU DE FIGURAS
  ;
   
   Cuadrado: 
      call LimpiaPantalla
      areaCuadrado  
      jmp Final
      
     
      
   Rectangulo: 
      call LimpiaPantalla
   
      areaRectangulo
      jmp Final
      
      
   Triangulo:     
      call LimpiaPantalla
      areaTriangulo
      jmp Final
      
   Circulo: 
     call LimpiaPantalla    
     areaCirculo
     jmp Final  
     
   
     
  
      
      
   
       
  ; 
  ;PROCEDIMIENTO PARA LIMPIAR PANTALLA
  ;
                                       
   LimpiaPantalla proc 
       MOV AH, 0Fh   
       INT 10h
       MOV AH, 0
       INT 10h 
       
       ret 
   endp 
   
   
   
   Final:     
   
    MOV DX,offset msgdib
       MOV AH, 09h
       INT 21h
       MOV AH,01h  
       INT 21h  
        
    ;Compara opcion escogida
    cmp OP, 1d 
    je DibCuadrado 
    
   
    cmp OP,2d 
    je DibRectangulo
    
    
    cmp OP,3d          
    je DibTriangulo
     
   
    cmp OP,4d          
    je DibCirculo 
    
    DibCuadrado:   
        w equ 50
        h equ 50


        ; set video mode 13h - 320x200

        square:   
                mov ah, 0
                mov al, 13h 
                int 10h


        ; draw upper line:

                mov cx, 100+w  ; column
                mov dx, 20     ; row
                mov al, 14     ; white
            u1: mov ah, 0ch    ; put pixel
                int 10h
    
                dec cx
                cmp cx, 100
                jae u1
 
        ; draw bottom line:

                mov cx, 100+w  ; column
                mov dx, 20+h   ; row
                mov al, 14     ; white
            u2: mov ah, 0ch    ; put pixel
                int 10h
    
                dec cx
                cmp cx, 100
                ja u2
 
        ; draw left line:

                mov cx, 100    ; column
                mov dx, 20+h   ; row
                mov al, 14     ; white
            u3: mov ah, 0ch    ; put pixel
                int 10h
    
                dec dx
                cmp dx, 20
                ja u3 
    
    
        ; draw right line:

                mov cx, 100+w  ; column
                mov dx, 20+h   ; row
                mov al, 14     ; white
            u4: mov ah, 0ch    ; put pixel
                int 10h
    
                dec dx
                cmp dx, 20
                ja u4     
 

        ; pause the screen for dos compatibility:

        ;wait for keypress
                mov ah,00
                int 16h			

        ; return to text mode:
                mov ah,00
                mov al,03 ;text mode 3
                int 10h



                jmp salida    
                
       DibRectangulo:   
        ww equ 25
        hh equ 40


        ; set video mode 13h - 320x200

        rectang:   
                mov ah, 0
                mov al, 13h 
                int 10h


        ; draw upper line:

                mov cx, 100+ww  ; column
                mov dx, 20     ; row
                mov al, 13     ; white
            v1: mov ah, 0ch    ; put pixel
                int 10h
    
                dec cx
                cmp cx, 100
                jae v1
 
        ; draw bottom line:

                mov cx, 100+ww  ; column
                mov dx, 20+hh   ; row
                mov al, 13     ; white
            v2: mov ah, 0ch    ; put pixel
                int 10h
    
                dec cx
                cmp cx, 100
                ja v2
 
        ; draw left line:

                mov cx, 100    ; column
                mov dx, 20+hh   ; row
                mov al, 13     ; white
            v3: mov ah, 0ch    ; put pixel
                int 10h
    
                dec dx
                cmp dx, 20
                ja v3 
    
    
        ; draw right line:

                mov cx, 100+ww  ; column
                mov dx, 20+hh   ; row
                mov al, 13     ; white
            v4: mov ah, 0ch    ; put pixel
                int 10h
    
                dec dx
                cmp dx, 20
                ja v4     
 

        ; pause the screen for dos compatibility:

        ;wait for keypress
                mov ah,00
                int 16h			

        ; return to text mode:
                mov ah,00
                mov al,03 ;text mode 3
                int 10h



                jmp salida 
                  
                  
             DibTriangulo:     
                  wt equ 50
                  ht equ 50

       triang:
        ; set video mode 13h - 320x200

        mov ah, 0
        mov al, 13h 
        int 10h


; linea de arriba:

    mov cx, 100+wt  ; column
    mov dx, 20     ; row
    mov al, 12     ; white
t1: mov ah, 0ch    ; put pixel
    int 10h
    
    dec cx
    cmp cx, 100
    jae t1
 

 

    
; linea derecha:

    mov cx, 100+wt  ; column
    mov dx, 20+ht   ; row
    mov al, 12     ; white
t4: mov ah, 0ch    ; put pixel
    int 10h
    
    dec dx
    cmp dx, 20
    ja t4 
     
; dibujar linea en diagonal:
     
    mov cx, 100+wt  ; column
    mov dx, 20+ht   ; row
    mov al, 12     ; white
t5: mov ah, 0ch    ; put pixel
    int 10h
    
    dec dx  
    dec cx
    cmp dx, 20
    ja t5      
 

; pause the screen for dos compatibility:

;wait for keypress
  mov ah,00
  int 16h			

; return to text mode:
  mov ah,00
  mov al,03 ;text mode 3
  int 10h
          
          jmp salida
       
       
 DibCirculo: 
                  
   mov ah, 0   ; set display mode function.
mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
int 10h     ; set it!

circle x, y, r

;wait for keypress
  mov ah,00
  int 16h

JMP Salida



Salida:
MOV ah,4ch
INT 21h  

END
