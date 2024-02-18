package main

import (
	"bufio"
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
	ctx := context.Background()
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
				companyArr[1],
				companyArr[2],
				companyArr[3],
				&location,
			})
		}
	}
	return companies
}

type Company struct {
	Name      string         `firestore:"name"`
	WasteType string         `firestore:"waste_type"`
	Address   string         `firestore:"address"`
	Phone     string         `firestore:"phone"`
	Location  *latlng.LatLng `firestore:"location"`
}
