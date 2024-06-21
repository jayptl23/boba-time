import SwiftUI

struct Card: View {
    
    var business: Business
    
    var body: some View {
        HStack() {
            image
            details
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.detail)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension Card {
    private var image: some View {
        AsyncImage(url: URL(string: business.imageUrl.isEmpty ? "https://www.honestfoodtalks.com/wp-content/uploads/2022/07/Coffee-boba-recipe-1.jpeg" : business.imageUrl), content: { returnedImage in
            returnedImage
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
        }, placeholder: {
            ProgressView()
                .frame(width: 100, height: 100)
        })
    }
    
    private var details: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(business.name)
                .font(.system(.title2, design: .default, weight: .bold))
            HStack(alignment: .center, spacing: 2) {
                Text(String(format: "Rating: %.1f", business.rating))
                    .fontWeight(.semibold)
                Image(systemName: "star.fill")
                    .font(.system(size: 13))
            }
            Text(business.location.displayAddress.joined(separator: "\n"))
                .font(.system(size: 15))
        }
        .foregroundColor(Theme.text)
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card(business: Business(
            id: "123",
            name: "Real Fruit Bubble Tea & Some More",
            imageUrl: "https://s3-media1.fl.yelpcdn.com/bphoto/3SeVDo2x6L_c-41shyvKDg/o.jpg",
            rating: 5.0,
            location: Business.Location(displayAddress: ["2458 Dundas St W", "Mississauga, ON L5K 1R8", "Canada"]),
            coordinates: Business.Coordinates(latitude: 43.498092, longitude: -79.612909)
        ))
            .previewLayout(.sizeThatFits)
    }
}
