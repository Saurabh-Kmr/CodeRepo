@IsTest
public class TriggerDtoTest {
  @IsTest
  public static void testDto() {
    new TriggerDto.Context();
    TriggerDto.Context ctx = new TriggerDto.Context('Account', TriggerOperation.BEFORE_INSERT);
    Assert.areEqual(true, ctx.isInsert);
    Assert.areEqual(true, ctx.isBeforeInsert);
    Assert.areEqual(true, ctx.isBefore);
    Assert.areEqual(false, ctx.isAfterInsert);
    Assert.areEqual(false, ctx.isAfter);

    ctx.newList = new List<Sobject>{ new Account(Id = '0013o00000AJq4LEAT', Name = 'New') };
    ctx.newMap = new Map<Id, Sobject>{ '0013o00000AJq4LEAT' => new Account(Id = '0013o00000AJq4LEAT', Name = 'New') };

    Assert.areEqual(new List<String>{ '0013o00000AJq4LEAT' }, ctx.getNewIds());
    ctx.oldMap = new Map<Id, Sobject>{ '0013o00000AJq4LEAT' => new Account(Id = '0013o00000AJq4LEAT', Name = 'Old') };
    Assert.areEqual('Old', ctx.getOld('0013o00000AJq4LEAT').get('Name'));
    Assert.areEqual('New', ctx.getNew('0013o00000AJq4LEAT').get('Name'));

    Assert.areEqual(false, ctx.isRecurring('0013o00000AJq4LEAT'));
    Assert.areEqual(true, ctx.isRecurring('0013o00000AJq4LEAT'));
  }
}
