package cinema.controller;

import cinema.model.Advertisement;
import cinema.repository.AdvertisementRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ads")
@CrossOrigin(origins = "*")
public class AdvertisementController {

    @Autowired
    private AdvertisementRepository advertisementRepository;

    @GetMapping
    public List<Advertisement> getActiveAds() {
        return advertisementRepository.findByActiveTrueOrderBySortOrderAscIdAsc();
    }

    @PostMapping
    public ResponseEntity<?> createAd(@RequestBody Advertisement ad) {
        return ResponseEntity.ok(advertisementRepository.save(ad));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAd(@PathVariable int id, @RequestBody Advertisement payload) {
        return advertisementRepository.findById(id)
                .map(ad -> {
                    ad.setTitle(payload.getTitle());
                    ad.setImageUrl(payload.getImageUrl());
                    ad.setLinkUrl(payload.getLinkUrl());
                    ad.setActive(payload.isActive());
                    ad.setSortOrder(payload.getSortOrder());
                    return ResponseEntity.ok(advertisementRepository.save(ad));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAd(@PathVariable int id) {
        advertisementRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
}
