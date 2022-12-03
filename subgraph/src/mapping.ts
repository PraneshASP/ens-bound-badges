import {
  Issued as IssuedEvent,
  Revoked as RevokedEvent,
} from "../generated/templates/ENSBoundBadge/ENSBoundBadge";
import { NewENSBoundBadgeCreated as NewENSBoundBadgeCreatedEvent } from "../generated/ENSBoundBadgeFactory/ENSBoundBadgeFactory";
import { BadgeHolder, ENSBoundBadge } from "../generated/schema";
import { sendEPNSNotification } from "./EPNSNotification";
import { log } from "@graphprotocol/graph-ts";
import { ENSBoundBadge as ENSBoundBadgeInstance } from "../generated/templates";

export const subgraphID = "praneshasp/ensboundbadge-test";

export function handleIssued(event: IssuedEvent): void {
  let id = `${event.address.toHexString()}+${event.params._badgeId.toString()}`;
  let entity = new BadgeHolder(id);
  entity.badgeId = event.params._badgeId;
  entity.holderAddress = event.params._recipientAddress;
  entity.holderENS = event.params._recipient;
  entity.issuedAt = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save();

  let ensBoundBadgeInstance = ENSBoundBadge.load(event.address);
  if (ensBoundBadgeInstance == null) {
  } else {
    let holders = ensBoundBadgeInstance.holders;
    holders.push(id);
    ensBoundBadgeInstance.holders = holders;
    ensBoundBadgeInstance.save();
  }
  // Send Push notification to the recipient of the badge
  let recipient = entity.holderAddress.toHexString(),
    type = "3",
    title = `Received a new Badge #${entity.badgeId.toString()}`,
    body = `Congrats! You are issued with a new badge for unlocking an achievement. Badge ID is #${entity.badgeId.toString()}`,
    subject = "New Badge Issued!",
    message = `Congrats! You received a new badge #${entity.badgeId.toString()}`,
    image =
      "https://static.vecteezy.com/system/resources/previews/009/373/589/non_2x/business-icon-success-3d-illustration-png.png",
    secret = "null",
    cta = "https://ethindia.co/";

  const notification = `{\"type\": \"${type}\", \"title\": \"${title}\", \"body\": \"${body}\", \"subject\": \"${subject}\", \"message\": \"${message}\", \"image\": \"${image}\", \"secret\": \"${secret}\", \"cta\": \"${cta}\"}`;
  sendEPNSNotification(recipient, notification);
  log.info("Notification Sent : {}", [entity.holderAddress.toHexString()]);
}

export function handleRevoked(event: RevokedEvent): void {
  let id = `${event.address.toHexString()}+${event.params._badgeId.toString()}`;

  let entity = BadgeHolder.load(id);
  if (entity) {
    entity.isRevoked = true;
    entity.revokedAt = event.block.timestamp;
    entity.save();

    // Send Push notification using EPNS
    let recipient = event.params._revokedFrom.toHexString(),
      type = "3",
      title = `Revoked a Badge - BadgeID #${entity.badgeId}`,
      body = `Oops! Your badge has been revoked. Badge ID is #${entity.badgeId}`,
      subject = "Badge Revoked!",
      message = `Oops! Your badge #${entity.badgeId} has been revoked`,
      image =
        "https://img.freepik.com/premium-vector/3d-check-wrong-icon-isolated-white-background-negative-check-list-button-choice-false-correct-tick-problem-fail-application-emergency-icon-vector-with-shadow-3d-rendering-illustration_412828-1336.jpg",
      secret = "null",
      cta = "https://ethindia.co/";

    const notification = `{\"type\": \"${type}\", \"title\": \"${title}\", \"body\": \"${body}\", \"subject\": \"${subject}\", \"message\": \"${message}\", \"image\": \"${image}\", \"secret\": \"${secret}\", \"cta\": \"${cta}\"}`;
    sendEPNSNotification(recipient, notification);
    log.info("Notification Sent : {}", [
      event.params._revokedFrom.toHexString(),
    ]);
  }
}

export function handleNewENSBoundBadgeCreation(
  event: NewENSBoundBadgeCreatedEvent
): void {
  let entity = new ENSBoundBadge(event.params._ensBoundBadgeAddress);
  entity.name = event.params._name;
  entity.symbol = event.params._symbol;
  entity.supply = event.params._supply;
  entity.createdAt = event.block.timestamp;
  entity.holders = [];
  entity.transactionHash = event.transaction.hash;
  entity.ensBoundBadgeAddress = event.params._ensBoundBadgeAddress;
  ENSBoundBadgeInstance.create(event.params._ensBoundBadgeAddress);
  entity.save();
}
