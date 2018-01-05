<aura:application >
    <aura:attribute name="sContactId" type="String" default="s"/>
    <aura:attribute name="sAppId" type="String" default="Hoila"/>
    <aura:attribute name="bIsReadOnly" type="Boolean" default="true" />
   
    <aura:if isTrue="{!and(v.sContactId == '', v.bIsReadOnly == true)}">
        {!v.sAppId}
    </aura:if>
</aura:application>