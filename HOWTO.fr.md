# Guide d'utilisation de Sha256Seal

Sha256Seal est une petite bibliothèque Ruby qui permet de signer des documents et de vérifier leur intégrité. Elle utilise HMAC-SHA-256 pour générer des signatures cryptographiques sécurisées.

## Concept principal

Le concept fondamental de Sha256Seal est de remplacer un champ spécifique dans une chaîne de caractères par une signature cryptographique. Cette signature est générée en utilisant :

1. La chaîne originale (avec le champ temporairement remplacé par une chaîne vide)
2. Une clé secrète

## Cas d'utilisation courants

- Signer des URLs pour prévenir la falsification (anti-CSRF)
- Vérifier l'intégrité des données transmises
- Créer des liens signés avec durée de validité limitée
- Protéger des formulaires contre la modification

## Installation

```ruby
# Dans votre Gemfile
gem "sha256_seal"

# Ou via la ligne de commande
gem install sha256_seal
```

## Exemples de base

### Signer un document

Lorsque vous voulez signer un document, vous devez inclure un champ placeholder qui sera remplacé par la signature.

```ruby
require 'sha256_seal'

# Document avec un placeholder pour la signature
document = "/.__SIGNATURE__/comptes/42?editable=false"
secret = "ma_cle_secrete"
placeholder = "__SIGNATURE__"

# Créer un builder et signer le document
builder = Sha256Seal::Builder.new(document, secret, placeholder)

# Obtenir le document signé
signed_document = builder.signed_value
# => "/.abc123def456.../comptes/42?editable=false"
```

### Vérifier un document signé

Pour vérifier un document déjà signé, vous devez connaître la clé secrète et fournir la signature actuelle comme "field".

```ruby
require 'sha256_seal'

# Document déjà signé
signed_document = "/.abc123def456.../comptes/42?editable=false"
secret = "ma_cle_secrete"
signature = "abc123def456..." # La signature extraite du document

# Créer un builder pour la vérification
builder = Sha256Seal::Builder.new(signed_document, secret, signature)

# Vérifier si le document est correctement signé
if builder.signed_value?
  puts "Document authentique ✓"
else
  puts "Document falsifié ✗"
end
```

## Intégration avec Rails

### Configuration initiale

```ruby
# config/initializers/sha256_seal.rb
SIGNATURE_SECRET = ENV.fetch("SIGNATURE_SECRET_KEY", "default_dev_key_do_not_use_in_production")
```

### Exemple de contrôleur Rails

```ruby
class SecureLinksController < ApplicationController
  def generate
    user_id = current_user.id
    timestamp = Time.now.to_i

    # Créer un lien avec un placeholder pour la signature
    unsigned_link = "/secure/__SIGNATURE__/resource/#{user_id}?t=#{timestamp}"

    # Signer le lien
    builder = Sha256Seal::Builder.new(unsigned_link, SIGNATURE_SECRET, "__SIGNATURE__")
    @signed_link = builder.signed_value
  end

  def verify
    # Extraire la signature du chemin
    path_components = request.path.split('/')
    signature = path_components[2] # Supposons que la signature est le 3ème composant

    # Vérifier la signature
    builder = Sha256Seal::Builder.new(request.original_url, SIGNATURE_SECRET, signature)

    if !builder.signed_value?
      render plain: "Lien non valide ou expiré", status: :forbidden
      return
    end

    # Continuer avec le traitement normal si la signature est valide
    # ...
  end
end
```

## Bonnes pratiques

1. **Stockez la clé secrète de manière sécurisée** : Utilisez des variables d'environnement ou un gestionnaire de secrets.

2. **Utilisez des clés différentes pour différents types de données** : Ne réutilisez pas la même clé pour différents contextes.

3. **Incluez des informations temporelles** : Pour les liens ou jetons qui doivent expirer, incluez un timestamp dans les données signées.

4. **Limitez la taille des données** : Évitez de signer de très grandes chaînes de caractères.

5. **Incluez des identifiants uniques** : Par exemple, incluez les IDs utilisateur dans les données signées pour limiter leur utilisation.

## Détails techniques

- Les signatures sont générées avec HMAC-SHA-256
- Le résultat est encodé en Base64 URL-safe sans padding
- Toutes les chaînes sont traitées comme UTF-8
- La taille maximale des données est limitée à 1 MB

## Dépannage

### La signature ne correspond pas

Causes possibles :
- La clé secrète a changé
- Le contenu du document a été modifié
- La signature a été altérée
- Encodage des caractères incorrect

### ArgumentError: "field must appear exactly once"

Cette erreur se produit lorsque :
- Le champ de signature n'apparaît pas dans la chaîne
- Le champ de signature apparaît plusieurs fois

## Sécurité

Cette bibliothèque utilise des algorithmes cryptographiques standards (HMAC-SHA-256) mais n'est pas un substitut à des mesures de sécurité complètes. Utilisez-la comme une couche de sécurité parmi d'autres dans votre application.
