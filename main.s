# ===== Section donnees =====
.data
    grille:       .space 100 #Grille de char de 10x10 soit 100 octet
    tailleA:    .word 5
    tailleB:    .word 4
    tailleC:    .word 3
    tailleS:    .word 3
    tailleD:    .word 2
    #variables globales pour le jeu
    nbLignesColonnes:  .word 10
    nb_coups:    .word 0
    nb_coups_but:     .word 0
    victoire_message: .asciiz "\n tous les navires ont ete coules ! "
    mancheSuivante: .asciiz "\n |------>Nombre de navires trouvés : "
    finitionMessage: .asciiz "\n le jeu est termine \n"
    messageLoupe: .asciiz "\n loupe ! \n"
    messageCoule: .asciiz "\n coule ! \n"
    messageTouche: .asciiz "\n touche ! \n"
    
    # macros 
    .eqv nb_colonnes, 10
    .eqv nb_lignes, 10
    .eqv taille_a, 5
    .eqv taille_b, 4
    .eqv taille_c, 3
    .eqv taille_d, 2
    .eqv taille_s, 3
    
# ===== Section code =====  
.text

# ----- Main ----- 
main:  # initialisation de la partie complete -> appel de toutes les Fonctions
    jal initPartie
    jal simulationJeu
    j   exit 

# ----- Fonctions -----

# ----- Fonction initPartie -----
# Objectif :  Génère une nouvelle partie à chaque appel
# Registres utilises : $a0, $a1

initPartie:  
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    jal initGrille
    li  $a0, taille_a
    li  $a1, 65 # 'A' pour Aircraft Carrier (Porte-Avion)
    jal setShip
    li  $a0, taille_b
    li  $a1, 66 # 'B' pour Battleship (Cuirassé)
    jal setShip
    li  $a0, taille_c
    li  $a1, 67 # 'C' pour Cruiser (Croiseur)
    jal setShip
    li  $a0, taille_s
    li  $a1, 83 # 'S' pour Submarine (Sous-marin)
    jal setShip
    li  $a0, taille_d
    li  $a1, 68 # 'D' pour Destroyer (Torpilleur)
    jal setShip

    lw      $ra, 0($sp)                 # On recharge la reference 
    add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction initGrille -----
# Objectif : Charge la grille avec '.' (Case vide)
# Registres utilises : $t[0-3]

initGrille:
    la      $t0, grille     # Chargement de l'adresse de la grille
    li      $t1, 0          # Initialisation du compteur de boucle dans $t1
    li      $t3, 46         # Charge la valeur ASCII de '.'
    boucle_initGrille:
        bge     $t1, 100, end_initGrille # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb		$t3, 0($t2)		# On place la valeur de $t3 à l'adresse contenue dans $t2
            addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur)
        j boucle_initGrille
    end_initGrille:  
        jr $ra

# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]

displayGrille:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    jal displayLettres
    la      $t0, grille     #Charge l'adresse de la grille dans $t0
    li      $t1, 0          #Initialisation du compteur de boucle dans $t1
    li $t2, 0 # boucle 10 pour compter pourchaque ligne
    li $t4 ,1 #ligne courante
    move $a1, $t4
    jal addLineCount
    boucle_displayGrille:
        bge     $t1, 100, end_displayGrille     # Si $t1 est plus grand ou egal a 100 alors branchement a end_displayGrille
        bge $t2, 10, dg_newLine
            add     $t3, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t3)              # load byte at $t2(adress) in $a0
	    jal printChar
	    jal printEspace

            addi    $t1, $t1, 1            # $t1 += 1;
            addi $t2, $t2, 1
        j boucle_displayGrille
    
    dg_newLine:
    	li $t2, 0
    	addi $t4, $t4, 1 #lignecOurante++
    	jal addNewLine
        move $a1, $t4
        jal addLineCount
    	j boucle_displayGrille
    	
    end_displayGrille: 
        jal     addNewLine
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction displayLettres -----
# Objectif : afficher les lettres de A à J
# Regitres utilises : $t0, $v0, $a0

#Lettres de A à J -> de 65 à 74 | 74 - 65 = 9
displayLettres:  
    sub $sp, $sp, 4
    sw $ra, 0($sp)
    li $t0, 65 #compteur avec 65 code ASCII de 'A'
    jal printEspace # eviter que ca décale au début
    jal printEspace
    jal printEspace
    displayLettres_start:
        bge $t0, 75, displayLettres_fin # while $t0 < 75 do
            move $a0, $t0 # ca part dans a0
            jal printChar #espace
            jal printEspace
            addi $t0, $t0, 1 # compteur++
            j displayLettres_start
    displayLettres_fin:  # fin fonction
        jal addNewLine #retour a la ligne
      	lw $ra, 0($sp)
	add $sp, $sp, 4
        jr $ra # fin fonction


#Fonction utilitaires print
# params :   ce qu'on veut afficher dans [$a0]
printChar:
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	li $v0, 11
	syscall
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra

printInt: 
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	li $v0, 1
	syscall
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra
	
printString:
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	li $v0, 4
	syscall
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra
	
printEspace:
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	li $a0, 32
	jal printChar #appel a printchar
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra


# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    sub $sp, $sp, 4
    sw $ra, 0($sp)
    li      $a0, 10 	# Chargement chaine à afficher -> '\n'
    jal printChar       # appel printchar
    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr      $ra         # Retour à la fonction précendente

# ----- Fonction addLineCount -----
# Objectif :   affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours :   res du modulo + 1)

addLineCount:
    sub $sp, $sp, 4
    sw $ra, 0($sp)

    move $a0, $a1
    jal printInt
    jal printEspace
    beq $a1,10 alc_fin # evite le décalage sur la dernier ligne
    jal printEspace # le 10 n'a pas besoin d'un espace en plus car 2 chiffres
    alc_fin:
    	lw $ra, 0($sp)
    	add $sp, $sp, 4
    	jr $ra

# ----- Fonction getModulo ----- 
# Objectif :   Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat (reste) dans :   $v0
# Resultat (quotient) dans : $v1
# Registres utilises : $a0 et $a1

getModulo:   
    li $v1, 0 # quotient de nouveau a 0
    sub     $sp, $sp, 4 # on alloue de la mémoire
    sw      $ra, 0($sp) # pour appels récursifs
    boucle_getModulo:
        blt $a0, $a1, end_getModulo # tant que a > b
        addi $v1, $v1, 1 #quotient++
        sub $a0, $a0, $a1 # a = a - b
        j boucle_getModulo
    end_getModulo:  
    move    $v0, $a0 # reste
    lw      $ra, 0($sp) # recharge du retour
    add     $sp, $sp, 4 # pile libération
    jr $ra

# ----- Fonction getAleatoire ----- 
# Objectif :  Génère un nombre aléatoire de 0 à n-1
#   $a1 represente la valeur max-1
# Resultat dans : $a0
# Registres utilises : $a0, $a1, $v0

getAleatoire:  
    li $v0, 42
    syscall
    jr $ra

# ----- Fontion setShip -----
# Objectif : place un bateau de taille donné.  
#   $a0 represente la taille en nombre de case du bateau à placer
#   $a1 represente le caraètre pour représenter le bateau
# Registres utilises : $a0, $a1, $s[0-4], $t[0-4]

setShip: 
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour

    move    $s0, $a0		# On recopie la taille dans $s0
    move    $s4, $a1        # On recopie le caractère du bateau
    try_setShip:
        #Choix de l'axe (horizontale ou verticale)
        li      $a1, 2          # Définition de la borne surpérieur (Resultat possbile :   0 ou 1)
        jal getAleatoire        # Saut pour obtenir une valeur aléatoire
        move 	$s1, $a0		# On copie le résultat dans $s1
        # Placement en fonction de l'axe
        beq     $s1, 1, placeVerticale  # Si la valuer est 1 alors le bateau sera placer verticalement
        j       placeHorizontale        # Si la valuer est 0 alors le bateau sera placer horizontalement

    end_setShip: 
        lw      $ra, 0($sp)
        add     $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra
        
# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]
# params : $a0 = taille bateau  $s4 = caractere du bateau

placeHorizontale:
    li $a1, 10
    jal getAleatoire
    move $s2, $a0 # $s2 = ligne taille

    li $t0, 10
    sub $a1, $t0, $s0 # $s0 = taille du navire
    jal getAleatoire
    move $s3, $a0 # $s3 = colonne
    
    # Vérification placement
    jal verifPlaceHorizontale
    bne $v0, $zero, try_setShip #si non placement retour à try_setShip

    la $t0, grille
    li $t1, 0 # compteur i = 0

    while_phorizontal: # tant que i < taille
        bge $t1, $s0, fin_phorizontal 

            li $t2, 10
            mult $s2, $t2 # numLigne * 10(taille ligne)
            mflo $t3 # résultat dans $t3
            add $t3, $t3, $s3 # + colonne
            add $t3, $t3, $t1 # + i
            add $t3, $t0, $t3 # adresse= grille + index
            # Écriture
            sb $s4, 0($t3) # grille[index]= caractère
            addi $t1, $t1, 1 # i++
            j while_phorizontal

    fin_phorizontal:
        j end_setShip


# ----- Fontion verifPlaceHorizontale -----
# Objectif :  verifie si le placement (horizontale) est possible.
# $s0 contient la taille du navire
# $s2 contient la ligne 
# $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3
# params : $s0 = taille bateau  $s2 = ligne  $s3 = colonne

verifPlaceHorizontale:
    sub $sp, $sp, 4
    sw $ra, 0($sp)
    la $t0, grille
    li $t1, 0# i= 0
    
    boucle_vph:
        bge $t1, $s0, vph_returntrue #tant que i < taille & placement ok
            li $t2, 10
            mult $s2, $t2
            mflo $t3
            add $t3, $t3, $s3
            add $t3, $t3, $t1
            add $t3, $t0, $t3
            lb $t4, 0($t3) # t4 = grille[index]
            #la place doit etre libre
            bne $t4, 46, vph_returnfalse #if t4 != . ca part dans false
            addi $t1, $t1, 1 # i++
            j boucle_vph
        
    vph_returntrue:
        li $v0, 0
        lw $ra, 0($sp)
        add $sp, $sp, 4
        jr $ra
    
    vph_returnfalse: 
        li $v0, 1
        lw $ra, 0($sp)
        add $sp, $sp, 4
        jr $ra

# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale. 
# Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]
# params : $a0 = taille bateau  $a1 = caractère bateau

placeVerticale: # similaire a placeHorizontale mais formule diférente
    li $t0, 10
    sub $a1, $t0, $s0
    jal getAleatoire
    move $s2, $a0  # ligne
    li $a1, 10
    jal getAleatoire
    move $s3, $a0  # colonne
    jal verifPlaceVerticale
    bne $v0, $zero, try_setShip
    
    la $t0, grille
    li $t1, 0 # compteur
    while_pvertical:
        bge $t1, $s0, fin_pvertical
        
        add $t2, $s2, $t1
        li $t3, 10
        mult $t2, $t3 # *10
        mflo $t2
        add $t2, $t2, $s3
        add $t2, $t0, $t2
        sb $s4, 0($t2)
        addi $t1, $t1, 1
        j while_pvertical
    
    fin_pvertical:
        j end_setShip

# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
# $s0 contient la taille du navire
# $s2 contient la ligne 
# $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceVerticale: 
    sub $sp, $sp, 4
    sw $ra, 0($sp)
    
    la $t0, grille
    li $t1, 0 #i= 0
    
    while_vpv:
        bge $t1, $s0, vpv_returntrue #tant que i < taille & placement ok
            
            add $t2, $s2, $t1
            li $t3, 10
            mult $t2, $t3
            mflo $t2
            add $t2, $t2, $s3
            add $t2, $t0, $t2

            lb $t4, 0($t2) #t4 = grille[index]
            bne $t4, 46, vpv_returnfalse #si t4 != . ca part dans false
            
            addi $t1, $t1, 1#i++
            j while_vpv
    
    vpv_returntrue:
        li $v0, 0
        lw $ra, 0($sp)
        add $sp, $sp, 4
        jr $ra
    
    vpv_returnfalse:
        li $v0, 1
        lw $ra, 0($sp)
        add $sp, $sp, 4
        jr $ra

# ----- Fonction simulationJeu -----
# Objectif :  Simule une partie avec une grille déjà générée.  
# Registres utilises :   $s[0-3]

simulationJeu:
    sub $sp, $sp, 4 # allouage pile
    sw $ra, 0($sp)

    while_simu:
    	la $s5, nb_coups_but
    	lw $s5, 0($s5) #recuperer valeur a chaque tour
        bge $s5, 17, fin_simu #tant que pas tous bateaux coulés
            # on génère un tir aléatoire
            la $a0, mancheSuivante
            jal printString
            move $a0, $s5
            jal printInt
            jal addNewLine
            
            li $a1, 10 #max aléatoire 
            jal getAleatoire # ligne aléa
            move $s0, $a0 #résultat dans $s0
            li $a1, 10 #max aléatoire 
            jal getAleatoire # col aléa
            move $s1, $a0 #résultat dans $s1
            #transferts pour les params de traque
            move $a0, $s0
            move $a1, $s1
            jal traque #apel de traque
            
            jal displayGrille #affichage apres tir
            j while_simu
    
    fin_simu: #liberation pile
        lw $ra, 0($sp)
        add $sp, $sp, 4
        la $a0, finitionMessage
        jal printString
        la $a0, victoire_message
        jal printString
        j exit

# ----- Fontion traque -----     
# Objectif : Vérifie la présence d'un navire et le traque de manière récursive
# Registres utilises : $t[0-9], $s[0-3]

# params : $a0 = ligne, $a1 = colonne
traque: 
    sub $sp, $sp, 16 #16 octets
    sw $ra, 0($sp)
    sw $s0, 4($sp) #sauvegarde ligne
    sw $s1, 8($sp) #sauvegarde colonne
    sw $s2, 12($sp) #sauvegarde case
    
    la $t0, grille #on charge l'adresse de la grille
    
    li $t2, 10 #10
    mult $s0, $t2 #ligne * 10
    mflo $t1 #
    add $t1, $t1, $s1 #+ colonne
    add $t2, $t0, $t1
    lb $s2, 0($t2) #contenu case actuelle dans $s2
    
    beq $s2, 126, fin_traque #cas déjà manqué '~'
    beq $s2, 88, fin_traque #cas déjà touché 'X'
    
    la $t4, nb_coups
    lw $t5, 0($t4)
    addi $t5, $t5, 1 #nb_coups++
    sw $t5, 0($t4)
    
    beq $s2, 46, dans_eau #cas "." -> dans l'eau
    
    #cas touché bateau
    la $t4, nb_coups_but #on charge l'adresse de nb_coups_but
    lw $t5, 0($t4) # charge nb_coups_but
    addi $t5, $t5, 1 #nb_coups_but++
    sw $t5, 0($t4) # on sauvegarde
    
    li $t3, 88 #"X"
    sb $t3, 0($t2) #on marque le tir touché
    la $a0, messageTouche
    jal printString
    
    #récursivité avec directions
    #nord
    sub $t1, $s0, 1
    blez $t1, cas_est #si ligne-1 < 0 passe à l'est
    cas_nord: #traque(ligne-1, colonne)
        move $a0, $t1
        move $a1, $s1
        jal traque
    
    #est
    cas_est: #traque(ligne, colonne+1)
        addi $t1, $s1, 1 # colonen++
        bge $t1, 10, cas_sud #si colonne+1 >= 10 passe au sud
        move $a0, $s0
        move $a1, $t1
        jal traque
    
    #sud
    cas_sud: #traque(ligne+1, colonne)
        addi $t1, $s0, 1 #ligne++
        bge $t1, 10, cas_ouest #si ligne+1 >= 10 passe à l'ouest
        move $a0, $t1
        move $a1, $s1
        jal traque
    
    #ouest
    cas_ouest: #traque(ligne, colonne-1)
        sub $t1, $s1, 1
        blez $t1, fin_traque #si colonne-1 < 0 fin
        move $a0, $s0
        move $a1, $t1
        jal traque
        j fin_traque
    
    dans_eau:
        li $t3, 126 #ASCII '~'
        sb $t3, 0($t2) #on marque le tir dans l'eau
        la $a0, messageLoupe
        jal printString
        j fin_traque
    
    fin_traque:
        #libération pile
        lw $s2, 12($sp)
        lw $s1, 8($sp)
        lw $s0, 4($sp)
        lw $ra, 0($sp)
        add $sp, $sp, 16
        jr $ra

exit:  
    li $v0, 10  #Chargement appel systeme 10 (Sortie)
    syscall
