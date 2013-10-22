#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static BHK my_hooks;
static int depth;

static void
my_start_hook(pTHX_ int full)
{
    ++depth;
}

static void
my_end_hook(pTHX_ OP **o)
{
    --depth;
}

static void
reset_block_hooks(pTHX_ void *p)
{
    BhkDISABLE(&my_hooks, bhk_start);
    BhkDISABLE(&my_hooks, bhk_pre_end);
}

static void
call_parse()
{
    dSP;

    ENTER;
    PUSHMARK(SP);
    call_pv("Devel::CompleteStatement::_call_parse", G_DISCARD);
    LEAVE;
}

MODULE = Devel::CompleteStatement  PACKAGE = Devel::CompleteStatement

PROTOTYPES: DISABLE

void
_parse()
  PREINIT:
    OP *o;
  CODE:
    ENTER;

    SAVEI8(PL_in_eval);
    PL_in_eval = EVAL_INEVAL;

    if (o = parse_stmtseq(0))
        op_free(o);

    LEAVE;

SV *
complete_statement(str)
    SV *str
  PREINIT:
    CV *evalcv;
  CODE:
    ENTER;
    SAVETMPS;
    SAVEDESTRUCTOR_X(reset_block_hooks, NULL);

    /* most of this copied from Parse::Perl */

    /* populate PL_compiling and related state */
    SAVECOPFILE_FREE(&PL_compiling);
    {
        char filename[TYPE_DIGITS(long) + 10];
        sprintf(filename, "(eval %lu)", (unsigned long)++PL_evalseq);
        CopFILE_set(&PL_compiling, filename);
    }
    SAVECOPLINE(&PL_compiling);
    CopLINE_set(&PL_compiling, 1);
    SAVEI32(PL_subline);
    PL_subline = 1;
    save_item(PL_curstname);
    sv_setpv(PL_curstname,
            !PL_curstash ? "<none>" : HvNAME_get(PL_curstash));
    SAVECOPSTASH_FREE(&PL_compiling);
    CopSTASH_set(&PL_compiling, PL_curstash);

    SAVECOMPILEWARNINGS();

    PL_hints |= HINT_LOCALIZE_HH;
    SAVEHINTS();
        HINT_BLOCK_SCOPE;

    SAVEI32(PL_compiling.cop_hints);
    PL_compiling.cop_hints = PL_hints;

    SAVEVPTR(PL_curcop);
    PL_curcop = &PL_compiling;
    /* initialise PL_compcv and related state */
    SAVEGENERICSV(PL_compcv);
    PL_compcv = (CV*)newSV_type(SVt_PVCV);
    CvANON_on(PL_compcv);
    CvOUTSIDE(PL_compcv) = NULL;
    CvOUTSIDE_SEQ(PL_compcv) = 0;
    CvPADLIST(PL_compcv) = pad_new(padnew_SAVE);
    /* initialise other parser state */
    SAVEOP();
    PL_op = NULL;
    SAVEGENERICSV(PL_beginav);
    PL_beginav = newAV();
    SAVEGENERICSV(PL_unitcheckav);
    PL_unitcheckav = newAV();
    lex_start(str, NULL, 0);

    depth = 0;
    BhkENABLE(&my_hooks, bhk_start);
    BhkENABLE(&my_hooks, bhk_pre_end);

    call_parse();

    RETVAL = (PL_parser->bufptr != PL_parser->bufend)
        ? &PL_sv_undef
        : (depth == 0)
        ? &PL_sv_yes
        : &PL_sv_no;

    FREETMPS;
    LEAVE;
  OUTPUT:
    RETVAL

BOOT:
    BhkENTRY_set(&my_hooks, bhk_start, my_start_hook);
    BhkENTRY_set(&my_hooks, bhk_pre_end, my_end_hook);
    Perl_blockhook_register(aTHX_ &my_hooks);
    reset_block_hooks(aTHX_ NULL);
