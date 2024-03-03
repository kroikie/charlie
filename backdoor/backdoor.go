package main

import (
	"bufio"
	"cloud.google.com/go/firestore"
	"context"
	firebase "firebase.google.com/go/v4"
	"fmt"
	"google.golang.org/genproto/googleapis/type/latlng"
	"os"
	"strconv"
	"strings"

	"log"
)

func main() {
	//SetClaims(context.Background(), "GpJKHNYEeQRD84Y8Ql5hQCH7ucp1")
	//UpdateCompanyWasteType(context.Background())
	WriteCompanies(context.Background())
}

func SetClaims(ctx context.Context, userId string) {
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	auth, _ := app.Auth(ctx)
	err = auth.SetCustomUserClaims(ctx, userId, map[string]interface{}{
		"user-type": "admin",
	})
	if err != nil {
		log.Fatalf("error setting custom claims: %v\n", err)
	}
}

func WriteCompanies(ctx context.Context) {
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	db, err := app.Firestore(ctx)
	companiesRef := db.Collection("companies")
	bulkWriter := db.BulkWriter(ctx)
	companies := ReadCompanies("companies.tsv")
	for _, company := range companies {
		fmt.Println(company)
		_, err := bulkWriter.Create(companiesRef.NewDoc(), company)
		if err != nil {
			log.Fatalf("error adding company to bulk writer: %v\n", err)
		}
	}
	bulkWriter.End()
}

func ReadCompanies(fileName string) []Company {
	var companies []Company
	file, err := os.Open(fileName)
	if err != nil {
		log.Fatalf("unable to read companies file: %v\n", err)
	}
	scanner := bufio.NewScanner(file)
	var lines []string
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	for _, line := range lines[1:] {
		companyArr := strings.Split(line, "\t")
		lat, _ := strconv.ParseFloat(companyArr[4], 64)
		lng, _ := strconv.ParseFloat(companyArr[5], 64)
		location := latlng.LatLng{Latitude: lat, Longitude: lng}
		if location.Latitude != 0 && location.Longitude != 0 {
			companies = append(companies, Company{
				companyArr[0],
				[]string{MapWasteType(companyArr[1])},
				companyArr[2],
				companyArr[3],
				&location,
			})
		}
	}
	return companies
}

func UpdateCompanyWasteType(ctx context.Context) {
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	db, err := app.Firestore(ctx)
	companiesRef := db.Collection("companies")
	docs, _ := companiesRef.Documents(ctx).GetAll()

	for _, doc := range docs {
		if doc.Data()["waste_type"] == "Bulky Waste" {
			_, _ = doc.Ref.Update(ctx, []firestore.Update{
				{Path: "waste_type", Value: "bulky"},
			})
		}
	}
}

type Company struct {
	Name      string         `firestore:"name"`
	WasteType []string       `firestore:"waste_types"`
	Address   string         `firestore:"address"`
	Phone     string         `firestore:"phone"`
	Location  *latlng.LatLng `firestore:"location"`
}

func MapWasteType(rawType string) string {
	switch rawType {
	case "Bulky Waste":
		return "bulky"
	case "E Waste":
		return "electronic"
	case "Batteries":
		return "batteries"
	case "Used Cooking Oil":
		return "usedCookingOil"
	case "Beverage Containers":
		return "beverageContainers"
	case "Organic Waste":
		return "organicWaste"
	case "Paper Waste":
		return "paper"
	case "Other":
		return "other"
	case "Car Oil":
		return "carOil"
	case "Scrap Metal":
		return "scrapMetal"
	case "Flourescent Bulbs/Tubes":
		return "flourescentBulbsTubes"
	case "Commercial":
		return "commercial"
	case "Pharmaceutical":
		return "pharmaceutical"
	case "White Waste: Solid Waste & Recyclable Material":
		return "whiteWaste"
	case "Organic waste (fruit and vegetable, newspaper)":
		return "organicWaste"
	case "Waste Oil and Domestic Garbage":
		return "wasteOilDomesticGarbage"
	default:
		return "general"
	}
}
