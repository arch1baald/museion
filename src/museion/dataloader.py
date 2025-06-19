import logging

import torch
from torch.utils.data import Dataset
from torchvision.datasets import CocoCaptions
from torchvision.transforms import Compose, PILToTensor, Resize

from museion._types import _TSplit
from museion.constants import ROOT

logger = logging.getLogger(__name__)


class TTMDataset(Dataset[tuple[torch.Tensor, str]]):
    def __init__(self, height: int, width: int, split: _TSplit = "train") -> None:
        self.images_dir = ROOT / "data" / "coco" / f"{split}2014"
        self.annotations_path = ROOT / "data" / "coco" / "annotations" / f"captions_{split}2014.json"
        self.coco = CocoCaptions(
            root=self.images_dir,
            annFile=str(self.annotations_path),
            transform=Compose([Resize((height, width)), PILToTensor()]),
        )

    def __len__(self) -> int:
        return len(self.coco)

    def __getitem__(self, index: int) -> tuple[torch.Tensor, str]:
        image, caption = self.coco[index]
        # TODO: clip
        return image, caption
