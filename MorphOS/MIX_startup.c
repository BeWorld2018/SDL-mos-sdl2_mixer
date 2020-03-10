#include "MIX_library.h"

/*********************************************************************/

int ThisRequiresConstructorHandling = 0;

/* This function must preserve all registers except r13 */
asm
("\n"
"	.section \".text\"\n"
"	.align 2\n"
"	.type __restore_r13, @function\n"
"__restore_r13:\n"
"	lwz 13, 36(3)\n"
"	blr\n"
"__end__restore_r13:\n"
"	.size __restore_r13, __end__restore_r13 - __restore_r13\n"
);

APTR libnix_mempool;

/**********************************************************************
	Startup/Cleanup
**********************************************************************/

int SAVEDS AMIGA_Startup(struct SDL2MixerLibrary *LibBase)
{
	struct CTDT *ctdt = LibBase->ctdtlist, *last_ctdt = LibBase->last_ctdt;

	// Run constructors
	while (ctdt < last_ctdt)
	{
		if (ctdt->priority >= 0)
		{
			if (ctdt->fp() != 0)
				return 0;
		}

		ctdt++;
	}

	return 1;
}

VOID SAVEDS AMIGA_Cleanup(struct SDL2MixerLibrary *LibBase)
{
	struct CTDT *ctdt = LibBase->ctdtlist, *last_ctdt = LibBase->last_ctdt;

	// Run destructors
	while (ctdt < last_ctdt)
	{
		if (ctdt->priority < 0)
		{
			if (ctdt->fp != (int (*)(void)) -1)
			{
				ctdt->fp();
			}
		}

		ctdt++;
	}
}

void __chkabort() { }
void abort() { }
